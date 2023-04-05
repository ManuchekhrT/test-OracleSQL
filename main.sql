CREATE TABLE ORDERS (
  ID INTEGER PRIMARY KEY,
  DOCDATE DATE
);

CREATE TABLE GOODS (
  ID INTEGER PRIMARY KEY,
  ORDER_ID INTEGER,
  GOOD_CODE VARCHAR2(255),
  PRICE NUMERIC,
  QUANTITY NUMERIC,
  FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ID)
);

CREATE PACKAGE ORDER_PKG AS

  FUNCTION ADD_GOODS(
    p_order_id INTEGER,
    p_good_code VARCHAR2(255),
    p_price NUMERIC,
    p_quantity NUMERIC
  ) RETURN INTEGER;

  FUNCTION INCR_GOODS(
    p_order_id INTEGER,
    p_good_code VARCHAR2(255),
    p_price NUMERIC,
    p_quantity NUMERIC
  ) RETURN INTEGER;

  PROCEDURE DELETE_ORDER(p_order_id INTEGER);

  FUNCTION GET_ORDERS(p_docdate DATE) RETURN SYS_REFCURSOR;

END;

CREATE PACKAGE BODY ORDER_PKG AS

  FUNCTION ADD_GOODS(
        p_order_id INTEGER,
        p_good_code VARCHAR2(255),
        p_price NUMERIC,
        p_quantity NUMERIC
        ) RETURN INTEGER IS
     v_goods_id INTEGER;
    BEGIN
    INSERT INTO GOODS (ORDER_ID, GOOD_CODE, PRICE, QUANTITY)
          VALUES (p_order_id, p_good_code, p_price, p_quantity)
     RETURNING ID INTO v_goods_id;
     RETURN v_goods_id;
    END;
  

  FUNCTION INCR_GOODS(
    p_order_id INTEGER,
    p_good_code VARCHAR2(255),
    p_price NUMERIC,
    p_quantity NUMERIC
  ) RETURN INTEGER IS
    v_goods_id INTEGER;
    v_qty INTEGER;
  BEGIN
    SELECT ID, QUANTITY INTO v_goods_id, v_qty
    FROM GOODS
    WHERE ORDER_ID = p_order_id AND GOOD_CODE = p_good_code;

    IF v_goods_id IS NULL THEN
      RETURN ADD_GOODS(p_order_id, p_good_code, p_price, p_quantity);
    ELSE
      UPDATE GOODS
      SET QUANTITY = v_qty + p_quantity
      WHERE ID = v_goods_id;
      RETURN v_goods_id;
    END IF;
  END;

  PROCEDURE DELETE_ORDER(p_order_id INTEGER) IS
  BEGIN
    DELETE FROM GOODS WHERE ORDER_ID = p_order_id;
    DELETE FROM ORDERS WHERE ID = p_order_id;
  END;

  FUNCTION GET_ORDERS(p_docdate DATE) RETURN SYS_REFCURSOR IS
    v_cur SYS_REFCURSOR;
  BEGIN
    OPEN v_cur FOR
      SELECT o.ID, o.DOCDATE, COUNT(*) AS "Кол-во товаров",
        SUM(g.PRICE * g.QUANTITY) AS "Общая стоимость"
      FROM ORDERS o
      JOIN GOODS g ON o.ID = g.ORDER_ID
      WHERE o.DOCDATE = p_docdate
      GROUP BY o.ID, o.DOCDATE;
    RETURN v_cur;
  END;

END;
