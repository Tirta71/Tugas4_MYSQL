-- 6.2

-- 1.	Buatlah bisnis proses pembayaran dengan menggunakan trigers, dengan skenario sebagai berikut :
-- - pelanggan memesan didalam table pesanan 
-- - dilanjutkan dengan proses pembayaran di table pembayaran
-- - didalam table pembayaran tambahkan kolom status_pembayaran
-- - jika pesanan sudah dibayar maka status pembayaran akan berubah menjadi lunas 
SELECT * FROM pesanan;
ALTER TABLE pembayaran ADD status_pembayaran varchar(25);
DELIMITER $$
CREATE TRIGGER cek_pembayaran
BEFORE INSERT ON pembayaran
FOR EACH ROW
BEGIN
  DECLARE total_bayar DECIMAL(10, 2);
  DECLARE total_pesanan DECIMAL(10, 2);
  SELECT SUM(jumlah) INTO total_bayar FROM pembayaran WHERE pesanan_id = NEW.pesanan_id;
  SELECT total INTO total_pesanan FROM pesanan WHERE id = NEW.pesanan_id;
  IF total_bayar >= total_pesanan THEN
    SET NEW.status_pembayaran = 'Lunas';
  END IF;
END$$
DELIMITER ;
INSERT INTO pembayaran (nokuitansi, tanggal, jumlah, ke, pesanan_id, status_pembayaran)
VALUES ('KWI001', '2023-03-03', 200000, 1, 1, 'Belum Lunas');

-- 2.	Buatlah Stored Procedure dengan nama kurangi_stok untuk mengurangi stok produk. Stok berkurang sesuai dengan jumlah pesanan produk.
DELIMITER $$
CREATE PROCEDURE kurangi_stok(IN produk_id INT, IN jumlah_pesanan INT)
BEGIN
  DECLARE stok_produk INT;
  
  -- Dapatkan jumlah stok produk saat ini
  SELECT stok INTO stok_produk FROM produk WHERE id = produk_id;
  
  -- Kurangi stok dengan jumlah pesanan
  SET stok_produk = stok_produk - jumlah_pesanan;
  
  -- Pastikan stok tidak negatif
  IF stok_produk < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Stok produk tidak mencukupi';
  END IF;
  
  -- Update stok produk yang telah dikurangi
  UPDATE produk SET stok = stok_produk WHERE id = produk_id;
END $$
DELIMITER ;


-- Jika Stok produk nya tidak mencukupi 
-- MariaDB [sib_6]> CALL kurangi_stok(1, 10);
-- ERROR 1644 (45000): Stok produk tidak mencukupi

-- Jika Stok produk nya mencukupi
-- MariaDB [sib_6]> CALL kurangi_stok(7, 2);
-- Query OK, 2 rows affected (0.001 sec)


-- 3.	Buatlah Trigger dengan nama trig_kurangi_stok yang akan mengurangi stok produk jika terjadi transaksi pesanan oleh pelanggan (memanggil stored procedure kurangi_stok soal no 1).
-- Trigger ini aktif setelah trigger after_pesanan_items_insert (trigger pada contoh 3).

DELIMITER $$
CREATE TRIGGER trig_kurangi_stok AFTER INSERT ON pesanan_items
FOR EACH ROW
BEGIN
  -- Memanggil stored procedure kurangi_stok untuk mengurangi stok produk
  CALL kurangi_stok(NEW.produk_id, NEW.qty);
END $$
DELIMITER ;

SELECT * FROM `produk`
-- +----+--------+-------------------+------------+------------+------+----------+------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------+
-- | id | kode   | nama              | harga_beli | harga_jual | stok | min_stok | foto                   | deskripsi                                                                                                                                                                                                           | jenis_produk_id |
-- +----+--------+-------------------+------------+------------+------+----------+------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------+
-- |  1 | TV01   | Televisi 21 inchs |    3500000 |   50500000 |    5 |        2 |                        | NULL                                                                                                                                                                                                                |               1 |
-- |  2 | TV02   | Televisi 40 inch  |    5500000 |    7440000 |    4 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- |  3 | K001   | Kulkas 2 pintu    |    3500000 |    4680000 |    6 |        2 |                        | NULL                                                                                                                                                                                                                |               1 |
-- |  4 | M001   | Meja Makan        |     500000 |     600000 |    4 |        3 | NULL                   | NULL                                                                                                                                                                                                                |               2 |
-- |  5 | TK01   | Teh Kotak         |       3000 |       3500 |    6 |       10 | foto-5.png             | NULL                                                                                                                                                                                                                |               4 |
-- |  6 | PC01   | PC Desktop HP     |    7000000 |    9984000 |    9 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               5 |
-- |  7 | TB01   | Teh Botol         |       2000 |       2500 |   51 |       10 | foto-7.jpg             | NULL                                                                                                                                                                                                                |               4 |
-- |  8 | AC01   | Notebook Acer S   |    8000000 |   11232000 |    7 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               5 |
-- |  9 | LN01   | Notebook Lenovo   |    9000000 |   12480000 |    9 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               5 |
-- | 11 | L005   | Laptop Lenovo     |   13000000 |   16000000 |    5 |        2 |                        | NULL                                                                                                                                                                                                                |               1 |
-- | 15 | L112   | Kopi              |      20000 |      30000 |   10 |       15 | foto-15.png            | Luwak White Coffee merupakan bubuk biji kopi luwak yang dikombinasikan dengan gurihnya krimer serta manisnya gula. Keharuman kopi serta rasa manisnya yang pas juga membuat popularitas Luwak White Coffee melejit. |               4 |
-- | 16 | L113   | Teh Sosro 2       |      10000 |      15000 |   10 |       12 | .png                   | NULL                                                                                                                                                                                                                |               1 |
-- | 18 | L0015  | Laptop Asus       |    3000000 |    5000000 |   10 |       20 | foto-65542ffa66604.jpg | NULL                                                                                                                                                                                                                |               1 |
-- | 19 | TV0115 | Televisi 22 inc`  |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 20 | TV0116 | Televisi 23 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 21 | TV0117 | Televisi 24 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 22 | TV0118 | Televisi 25 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 24 | TV0120 | Televisi 27 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 25 | TV0121 | Televisi 28 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 26 | TV0122 | Televisi 29 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 27 | THP001 | Teh Pucuk         |       4000 |       5000 |   10 |        2 | pucuk.jpg              | Teh pucuk adalah                                                                                                                                                                                                    |               4 |
-- | 28 | THP002 | Teh Pucuk2        |       4000 |       5000 |   10 |        2 | pucuk.jpg              | Teh pucuk adalah                                                                                                                                                                                                    |               4 |
-- | 41 | P001   | Produk 1          |      10000 |      15000 |   15 |        5 | foto1.jpg              | Deskripsi Produk 1                                                                                                                                                                                                  |               1 |
-- | 42 | P002   | Produk 2          |      12000 |      18000 |    8 |        5 | foto2.jpg              | Deskripsi Produk 2                                                                                                                                                                                                  |               1 |
-- | 43 | P003   | Produk 3          |      15000 |      20000 |    5 |        5 | foto3.jpg              | Deskripsi Produk 3                                                                                                                                                                                                  |               1 |
-- +----+--------+-------------------+------------+------------+------+----------+------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------+

INSERT INTO pesanan_items (produk_id, pesanan_id, qty, harga) VALUES 
(7, 3, 2, 7000)

SELECT * FROM `produk`
-- +----+--------+-------------------+------------+------------+------+----------+------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------+
-- | id | kode   | nama              | harga_beli | harga_jual | stok | min_stok | foto                   | deskripsi                                                                                                                                                                                                           | jenis_produk_id |
-- +----+--------+-------------------+------------+------------+------+----------+------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------+
-- |  1 | TV01   | Televisi 21 inchs |    3500000 |   50500000 |    5 |        2 |                        | NULL                                                                                                                                                                                                                |               1 |
-- |  2 | TV02   | Televisi 40 inch  |    5500000 |    7440000 |    4 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- |  3 | K001   | Kulkas 2 pintu    |    3500000 |    4680000 |    6 |        2 |                        | NULL                                                                                                                                                                                                                |               1 |
-- |  4 | M001   | Meja Makan        |     500000 |     600000 |    4 |        3 | NULL                   | NULL                                                                                                                                                                                                                |               2 |
-- |  5 | TK01   | Teh Kotak         |       3000 |       3500 |    6 |       10 | foto-5.png             | NULL                                                                                                                                                                                                                |               4 |
-- |  6 | PC01   | PC Desktop HP     |    7000000 |    9984000 |    9 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               5 |
-- |  7 | TB01   | Teh Botol         |       2000 |       2500 |   49 |       10 | foto-7.jpg             | NULL                                                                                                                                                                                                                |               4 |
-- |  8 | AC01   | Notebook Acer S   |    8000000 |   11232000 |    7 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               5 |
-- |  9 | LN01   | Notebook Lenovo   |    9000000 |   12480000 |    9 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               5 |
-- | 11 | L005   | Laptop Lenovo     |   13000000 |   16000000 |    5 |        2 |                        | NULL                                                                                                                                                                                                                |               1 |
-- | 15 | L112   | Kopi              |      20000 |      30000 |   10 |       15 | foto-15.png            | Luwak White Coffee merupakan bubuk biji kopi luwak yang dikombinasikan dengan gurihnya krimer serta manisnya gula. Keharuman kopi serta rasa manisnya yang pas juga membuat popularitas Luwak White Coffee melejit. |               4 |
-- | 16 | L113   | Teh Sosro 2       |      10000 |      15000 |   10 |       12 | .png                   | NULL                                                                                                                                                                                                                |               1 |
-- | 18 | L0015  | Laptop Asus       |    3000000 |    5000000 |   10 |       20 | foto-65542ffa66604.jpg | NULL                                                                                                                                                                                                                |               1 |
-- | 19 | TV0115 | Televisi 22 inc`  |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 20 | TV0116 | Televisi 23 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 21 | TV0117 | Televisi 24 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 22 | TV0118 | Televisi 25 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 24 | TV0120 | Televisi 27 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 25 | TV0121 | Televisi 28 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 26 | TV0122 | Televisi 29 inc   |    3500000 |   50500000 |    5 |        2 | NULL                   | NULL                                                                                                                                                                                                                |               1 |
-- | 27 | THP001 | Teh Pucuk         |       4000 |       5000 |   10 |        2 | pucuk.jpg              | Teh pucuk adalah                                                                                                                                                                                                    |               4 |
-- | 28 | THP002 | Teh Pucuk2        |       4000 |       5000 |   10 |        2 | pucuk.jpg              | Teh pucuk adalah                                                                                                                                                                                                    |               4 |
-- | 41 | P001   | Produk 1          |      10000 |      15000 |   15 |        5 | foto1.jpg              | Deskripsi Produk 1                                                                                                                                                                                                  |               1 |
-- | 42 | P002   | Produk 2          |      12000 |      18000 |    8 |        5 | foto2.jpg              | Deskripsi Produk 2                                                                                                                                                                                                  |               1 |
-- | 43 | P003   | Produk 3          |      15000 |      20000 |    5 |        5 | foto3.jpg              | Deskripsi Produk 3                                                                                                                                                                                                  |               1 |
-- +----+--------+-------------------+------------+------------+------+----------+------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------+