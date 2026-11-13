"""行政事業レビュー見える化サイト (RS システム) のレビューシートの CSV を取得する。

CSV は年度ごとに https://rssystem.go.jp/files/{年度}/rs/{名前}.zip で配布されている。
CSV の配布は 2024 年度のシートから。2024 年度から翌年までの年度を順に試し、ZIP が無い年度は飛ばす。
ZIP の無い URL にはサイトの画面の HTML が 200 で返るので、本文が ZIP かで判定する。
(画面が読む /api/projects/fiscal-years/ は GitHub のランナーから空の本文が返ったので使わない)

出力: data/{年度}/{番号}.csv (例 data/2025/1-2.csv)
ZIP の中のファイル名は #Uxxxx の表記になっていることがあるので、番号で付け直す。
"""

import datetime
import io
import logging
import zipfile
from pathlib import Path
from urllib.parse import quote

from shared.fetch import fetch, write_atomic

logger = logging.getLogger("pipelines")

SITE = "https://rssystem.go.jp"
USER_AGENT = "dataset-rssystem (+https://github.com/queria-io/dataset-rssystem)"
DATA = Path("data")
# 画面のダウンロードボタンと同じ要求にする
HEADERS = {"Accept": "application/zip,*/*", "Referer": f"{SITE}/download-csv"}

# 取得する CSV。番号と、ZIP の名前の「RS_{年度}_」より後ろ
FILES = {
    "1-2": "基本情報_事業概要等",
    "1-3": "基本情報_政策・施策、法令等",
    "2-1": "予算・執行_サマリ",
}


FIRST_YEAR = 2024


def fiscal_years() -> list[int]:
    return list(range(FIRST_YEAR, datetime.date.today().year + 2))


def zip_url(year: int, number: str) -> str:
    name = f"{number}_RS_{year}_{FILES[number]}.zip"
    return f"{SITE}/files/{year}/rs/{quote(name)}"


def extract_csv(body: bytes) -> bytes:
    with zipfile.ZipFile(io.BytesIO(body)) as archive:
        (member,) = [n for n in archive.namelist() if n.lower().endswith(".csv")]
        return archive.read(member)


def fetch_zip(url: str) -> bytes | None:
    body = fetch(url, headers=HEADERS, user_agent=USER_AGENT, not_found_ok=True)
    if body is not None and body.startswith(b"PK"):
        return body
    snippet = body[:120].decode("utf-8", "replace") if body is not None else "404"
    logger.info("  ZIP ではない (%d バイト): %s: %r", len(body or b""), url, snippet)
    return None


def download_year(year: int) -> bool:
    """year の CSV をすべて書き、その年度の ZIP が配布されていたかを返す。"""
    bodies = {n: fetch_zip(zip_url(year, n)) for n in FILES}
    if all(b is None for b in bodies.values()):
        return False
    missing = [n for n, b in bodies.items() if b is None]
    if missing:
        raise SystemExit(f"{year} 年度の ZIP の一部が無い: {missing}")
    for number, body in bodies.items():
        path = DATA / str(year) / f"{number}.csv"
        path.parent.mkdir(parents=True, exist_ok=True)
        write_atomic(path, extract_csv(body))
    return True


def download() -> None:
    years = [y for y in fiscal_years() if download_year(y)]
    if not years:
        raise SystemExit("レビューシートの CSV が 1 年度も取れない")
    logger.info("  年度: %s", years)
