
----------TABLE FOR  CUSTOMERS
CREATE TABLE customers (customer_id     NUMBER PRIMARY KEY,
                                                    name            VARCHAR2(100),
                                                    contact_no      VARCHAR2(15),
                                                     email           VARCHAR2(100)
);

                         
----------TABLE FOR PRODUCTS

CREATE TABLE products (
    product_id      NUMBER PRIMARY KEY,
    name            VARCHAR2(100),
    unit_price      NUMBER(10,2),
    stock_quantity  NUMBER
);


----------TABLE FOR  INVOICES

CREATE TABLE invoices (
    invoice_id      NUMBER PRIMARY KEY,
    customer_id     NUMBER,
    invoice_date    DATE DEFAULT SYSDATE,
    total_amount    NUMBER(10,2),
    tax_amount      NUMBER(10,2),
    discount_amount NUMBER(10,2),
    grand_total     NUMBER(10,2),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
                                     
----------TABLE FOR INVOICE_ITEMS

CREATE TABLE invoice_items (invoice_item_id NUMBER PRIMARY KEY,
                                                          invoice_id      NUMBER,
                                                          product_id      NUMBER,
                                                          quantity        NUMBER,
                                                          item_price      NUMBER(10,2),
    CONSTRAINT fk_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);
                                                                                                        
---------------FUNCTION FOR CALCULATION 

CREATE OR REPLACE FUNCTION calc_grand_total
(p_invoice_id NUMBER)
RETURN NUMBER IS
    v_total NUMBER := 0;
    v_tax   NUMBER;
    v_discount NUMBER;
BEGIN
    SELECT SUM(item_price * quantity) INTO v_total
    FROM invoice_items
    WHERE invoice_id = p_invoice_id;

    v_tax := v_total * 0.18;
    v_discount := CASE WHEN v_total > 5000 THEN v_total * 0.05 ELSE 0 END;

    RETURN v_total + v_tax - v_discount;
END;
-----------------------------PROCEDURE

CREATE OR REPLACE PROCEDURE add_invoice_item (
    p_invoice_item_id IN NUMBER,
    p_product_id IN NUMBER,
    p_quantity   IN NUMBER,
    p_invoice_id  IN NUMBER
) 
IS
    v_unit_price NUMBER;
    v_stock NUMBER;
BEGIN
    SELECT unit_price
                 , stock_quantity
    INTO      v_unit_price
                  , v_stock
    FROM products 
    WHERE product_id = p_product_id;

    IF p_quantity > v_stock THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock');
    END IF;

    INSERT INTO invoice_items(invoice_item_id
                                                  ,invoice_id
                                                  ,product_id
                                                  ,quantity
                                                  ,item_price
                                                  )
    VALUES                               (item_seq.NEXTVAL
                                                ,p_invoice_id 
                                                , p_product_id
                                                , p_quantity
                                                ,v_unit_price);


    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE product_id = p_product_id;
END;
-----------------------------------Sequence
CREATE SEQUENCE item_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;
--------------------------------TRIGGERS FOR CHECKING STOCK

CREATE OR REPLACE TRIGGER trg_check_stockss
BEFORE INSERT OR UPDATE ON invoice_items
FOR EACH ROW
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT stock_quantity
     INTO v_stock 
     FROM products
    WHERE product_id = :NEW.product_id;

    IF v_stock < :NEW.quantity THEN
        RAISE_APPLICATION_ERROR(-20001, 'Not enough stock available');
    END IF;
END;
---------------FUNCTION TO GET INCOICE

CREATE OR REPLACE FUNCTION get_invoice_summary(p_invoice_id NUMBER)
RETURN VARCHAR2 IS
    v_total NUMBER;
    v_result VARCHAR2(1000);
BEGIN
    v_total := calc_grand_total(p_invoice_id);
    v_result := 'Invoice ID: ' || p_invoice_id || CHR(10) ||
                'Grand Total: ' || v_total;

    RETURN v_result;
END;

------------- INSERTING   VALUES 

INSERT INTO customers(customer_id
                                            ,name
                                            ,contact_no
                                            ,email
                                            ) 
VALUES                          (1
                                        , 'John Doe'
                                        , '1234567890'
                                        , 'john@example.com'
                                        );

INSERT INTO products (customer_id
                                            ,name
                                            ,contact_no
                                            ,email
                                            )
 VALUES                          (101
                                         , 'Laptop'
                                         , 40000
                                           , 10
                                           );

INSERT INTO   Products(Product_Id
                                             ,Name
                                             ,Unit_Price
                                             ,Stock_Quantity
                                             )                            
 VALUES                         (102
                                        , 'Mouse'
                                        , 50000
                                      , 50);

INSERT INTO invoices(invoice_id
                                          ,customer_id
                                          ,invoice_date
                                          ,total_amount
                                          ,tax_amount
                                          ,discount_amount
                                          ,grand_total
                                          )
                                          
VALUES                                  (1001
                                         , 1
                                         , SYSDATE
                                         ,20000
                                         ,600
                                         ,200
                                         ,20000
                                          );
