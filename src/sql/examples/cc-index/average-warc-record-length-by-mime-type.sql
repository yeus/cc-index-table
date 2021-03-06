--
-- Calculate the average length and the occupied storage of WARC records by MIME type.
--
-- Update Dec 2019: add histogram counting reasons for payload truncation
-- Content payload in Common Crawl archives is truncated if the content exceeds a limit of
--  * 1 MiB in WARC files since 2013
--  * 500 kiB in the 2008 – 2012 ARC files
-- The truncation is required to keep the crawl archives at a limited size and ensure
-- that a broad sample of web pages is covered. It also avoids that the archives are filled
-- by accidentally captured video or audio streams. The crawler needs to buffer the content
-- temporarily and a limit ensures that this is possible with a limited amount of RAM for
-- many parallel connections. See also
--   https://iipc.github.io/warc-specifications/specifications/warc-format/warc-1.1/#warc-truncated
-- The column `content_truncated` has been added in November 2019 (CC-MAIN-2019-47)
-- to the URL indexes to skip over truncated captures instantly. Here the column is used to measure
-- the impact of the truncation on various document formats (MIME types).
--
SELECT COUNT(*) as n_pages,
       COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as perc_pages,
       AVG(warc_record_length) as avg_warc_record_length,
       SUM(warc_record_length) as sum_warc_record_length,
       SUM(warc_record_length) * 100.0 / SUM(SUM(warc_record_length)) OVER() as perc_warc_storage,
       content_mime_detected,
       histogram(content_truncated)
FROM "ccindex"."ccindex"
WHERE crawl = 'CC-MAIN-2019-47'
  AND subset = 'warc'
GROUP BY content_mime_detected
ORDER BY n_pages DESC;
