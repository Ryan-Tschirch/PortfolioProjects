SELECT PaymentType,
	   SUM (CASE WHEN 0 <= TotalPrice AND TotalPrice < 10 THEN 1 ELSE 0 END) AS "0-10",
	   SUM (CASE WHEN 10 <= TotalPrice AND TotalPrice < 100 THEN 1 ELSE 0 END) AS "10-100",
	   SUM (CASE WHEN 100 <= TotalPrice AND TotalPrice < 1000 THEN 1 ELSE 0 END) AS "100-1000",
	   SUM (CASE WHEN TotalPrice  >= 1000 THEN 1 ELSE 0 END) AS "1000+",
	   COUNT(*) AS "TOTAL",
	   SUM(TotalPrice) AS "REVENUE"
	   
FROM Company..Orders
GROUP BY PaymentType
ORDER BY PaymentType