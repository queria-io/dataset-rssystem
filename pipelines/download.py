"""行政事業レビュー見える化サイト (RS システム) のレビューシートの CSV を取得する。

CSV は年度ごとに https://rssystem.go.jp/files/{年度}/rs/{名前}.zip で配布されている。
CSV の配布は 2024 年度のシートから。2024 年度から翌年までの年度を順に試し、ZIP が無い年度は飛ばす。
ZIP の無い URL にはサイトの画面の HTML が 200 で返るので、本文が ZIP かで判定する。
(画面が読む /api/projects/fiscal-years/ は GitHub のランナーから空の本文が返ったので使わない)
GitHub Actions のランナーからは、2026 年 11 月時点でどの URL にも画面の HTML が返り、ZIP を取得できない。

出力: data/{年度}/{番号}.csv (例 data/2025/1-2.csv) と、取得した ZIP の記録 data/source_file.parquet (ZIP 本体は残さない)
ZIP の中のファイル名は #Uxxxx の表記になっていることがあるので、番号で付け直す。
5-1 支出先は、支出先と契約が行の並びで支出先ブロックに結び付く。先頭に行番号の列を足して書く。
"""

import csv
import datetime
import io
import logging
import tempfile
import zipfile
from pathlib import Path
from urllib.error import HTTPError
from urllib.parse import quote

from pipelines.source_file import write_source_files
from shared.fetch import fetch_file, write_atomic

logger = logging.getLogger("pipelines")

SITE = "https://rssystem.go.jp"
USER_AGENT = "dataset-rssystem (+https://github.com/queria-io/dataset-rssystem)"
DATA = Path("data")

# 取得する CSV。番号と、ZIP の名前の「RS_{年度}_」より後ろ
FILES = {
    "1-2": "基本情報_事業概要等",
    "1-3": "基本情報_政策・施策、法令等",
    "2-1": "予算・執行_サマリ",
    "5-1": "支出先_支出情報",
}

# 行の並びに意味がある CSV。先頭に「行番号」の列を足す
NUMBERED = {"5-1"}


FIRST_YEAR = 2024
# models/ は 2025 年度までのシートと 2026 年度のシートの両方の列名を読む。この年度まで取れなければ止める
FORMAT_CHANGE_YEAR = 2026


def fiscal_years() -> list[int]:
    return list(range(FIRST_YEAR, datetime.date.today().year + 2))


def zip_url(year: int, number: str) -> str:
    name = f"{number}_RS_{year}_{FILES[number]}.zip"
    return f"{SITE}/files/{year}/rs/{quote(name)}"


def extract_csv(path: Path) -> bytes:
    with zipfile.ZipFile(path) as archive:
        (member,) = [n for n in archive.namelist() if n.lower().endswith(".csv")]
        return archive.read(member)


def number_lines(body: bytes) -> bytes:
    rows = csv.reader(io.StringIO(body.decode("utf-8-sig"), newline=""))
    out = io.StringIO(newline="")
    writer = csv.writer(out, lineterminator="\n")
    writer.writerow(["行番号", *next(rows)])
    writer.writerows([i, *row] for i, row in enumerate(rows, start=1))
    return out.getvalue().encode("utf-8")


def fetch_zip(url: str, path: Path) -> dict | None:
    """url の ZIP を path に取得して source_file の行を返す。ZIP が無ければ None。"""
    try:
        source = fetch_file(url, path, user_agent=USER_AGENT)
    except HTTPError as error:
        if error.code != 404:
            raise
        logger.info("  ZIP ではない (404): %s", url)
        return None
    with path.open("rb") as f:
        head = f.read(120)
    if head.startswith(b"PK"):
        return source
    logger.info("  ZIP ではない (%d バイト): %s: %r", source["bytes"], url, head.decode("utf-8", "replace"))
    return None


def download_year(year: int, tmp: Path) -> list[dict]:
    """year の CSV をすべて書き、取得した ZIP の source_file の行を返す。その年度の ZIP が無ければ空。"""
    zips = {n: tmp / f"{year}_{n}.zip" for n in FILES}
    sources = {n: fetch_zip(zip_url(year, n), zips[n]) for n in FILES}
    if all(s is None for s in sources.values()):
        return []
    missing = [n for n, s in sources.items() if s is None]
    if missing:
        raise SystemExit(f"{year} 年度の ZIP の一部が無い: {missing}")
    for number in FILES:
        path = DATA / str(year) / f"{number}.csv"
        path.parent.mkdir(parents=True, exist_ok=True)
        content = extract_csv(zips[number])
        write_atomic(path, number_lines(content) if number in NUMBERED else content)
    return [{**sources[n], "page_url": f"{SITE}/download-csv", "paths": [str(DATA / str(year) / f"{n}.csv")]} for n in FILES]


def download() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        fetched = {y: download_year(y, Path(tmp)) for y in fiscal_years()}
    years = [y for y, sources in fetched.items() if sources]
    if not years:
        raise SystemExit("どの年度の ZIP も取得できなかった。rssystem.go.jp はこの実行環境の IP アドレスからの取得に画面の HTML を返していることがある")
    # 途中の年度だけ取れないと、その年度のない版を公開してしまう。2024 年度から続いていなければ止める
    if years != list(range(FIRST_YEAR, FIRST_YEAR + len(years))):
        raise SystemExit(f"レビューシートの CSV の年度が 2024 年度から続いていない: {years}")
    if years[-1] < FORMAT_CHANGE_YEAR:
        raise SystemExit(f"{FORMAT_CHANGE_YEAR} 年度のシートの CSV を取得できなかった: {years}")
    write_source_files([s for sources in fetched.values() for s in sources], DATA / "source_file.parquet")
    logger.info("  年度: %s", years)
