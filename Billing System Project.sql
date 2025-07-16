
----------TABLE FOR  Customers
CREATE TABLE customers (
    customer_id     NUMBER PRIMARY KEY,
    name            VARCHAR2(100),
    contact_no      VARCHAR2(15),
    email           VARCHAR2(100)
);


----------TABLE FOR products

CREATE TABLE products (
    product_id      NUMBER PRIMARY KEY,
    name            VARCHAR2(100),
    unit_price      NUMBER(10,2),
    stock_quantity  NUMBER
);
----------TABLE FOR  invoices
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
----------TABLE FOR invoice_items

CREATE TABLE invoice_items (
    invoice_item_id NUMBER PRIMARY KEY,
    invoice_id      NUMBER,
    product_id      NUMBER,
    quantity        NUMBER,
    item_price      NUMBER(10,2),
    CONSTRAINT fk_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

---------------FUNCTION FOR CALCULATION 
CREATE OR REPLACE FUNCTION calc_grand_total(p_invoice_id NUMBER)
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

------------TRIGGERS FOR CHECKING STOCK
CREATE OR REPLACE TRIGGER trg_check_stockss
BEFORE INSERT OR UPDATE ON invoice_items
FOR EACH ROW
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT stock_quantity INTO v_stock FROM products WHERE product_id = :NEW.product_id;

    IF v_stock < :NEW.quantity THEN
        RAISE_APPLICATION_ERROR(-20001, 'Not enough stock available');
    END IF;
END;



