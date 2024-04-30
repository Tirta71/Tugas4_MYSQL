-- 1.	Buatlah Procedure untuk mengupdate harga_jual berdasarkan jenis produk tertentu (jenis_produk_id), beri nama procedure pro_naikan_harga memiliki parameter yang akan menerima argumen: Jenis Produk ID dan Persentase kenaikan harga.
DELIMITER $$
CREATE PROCEDURE pro_naikan_harga(IN jenis_produk_id INT, IN persentase DOUBLE)
BEGIN
  UPDATE produk SET harga_jual = harga_jual * (1 + persentase / 100)
  WHERE jenis_produk_id = jenis_produk_id;
END$$
DELIMITER ;

CALL pro_naikan_harga(1, 10);
-- Query OK, 25 rows affected (0.001 sec)

-- 2.	Buat fungsi umur dengan parameter yang menerima inputan argumen tipe data date dan mengembalikan hasil perhitungan umur (tahun sekarang dikurang tahun inputan) dengan tipe data bilangan bulat (integer) positif.

DELIMITER $$
CREATE FUNCTION umur(tanggal_lahir DATE)
RETURNS INT
BEGIN
  DECLARE umur INT;
  SELECT YEAR(CURDATE()) - YEAR(tanggal_lahir) - (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(tanggal_lahir, '%m%d')) INTO umur;
  RETURN umur;
END$$
DELIMITER ;

SELECT umur('1997-02-03');
-- +--------------------+
-- | umur('1997-02-03') |
-- +--------------------+
-- |                 27 |
-- +--------------------+

-- 3.	Buat fungsi kategori_harga dengan parameter yang menerima inputan argument tipe data double dan mengembalikan tipe data string kategori harga berdasarkan: 
-- ●	0 – 500rb : murah
-- ●	500rb – 3 juta : sedang
-- ●	3jt – 10 juta : mahal 
-- ●	> 10 juta : sangat mahal


DELIMITER $$
CREATE FUNCTION kategori_harga(harga DOUBLE)
RETURNS VARCHAR(20)
BEGIN
  DECLARE kategori VARCHAR(20);
  IF harga <= 500 THEN
    SET kategori = 'murah';
  ELSEIF harga <= 3000000 THEN
    SET kategori = 'sedang';
  ELSEIF harga <= 10000000 THEN
    SET kategori = 'mahal';
  ELSE
    SET kategori = 'sangat mahal';
  END IF;
  RETURN kategori;
END$$
DELIMITER ;


SELECT kategori_harga(1000000);
-- +-------------------------+
-- | kategori_harga(1000000) |
-- +-------------------------+
-- | sedang                  |
-- +-------------------------+
