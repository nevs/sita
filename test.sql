
CREATE OR REPLACE FUNCTION vuln_sql_injection_direct( stmt text ) RETURNS VOID AS $$
  DECLARE
    var1 text;
    var2 text;
  BEGIN
    IF true THEN  -- line 5
      SELECT 6;
      var1 := quote_ident( stmt );
      IF false THEN
        SELECT 9;
      ELSE
        SELECT 11;
      END IF;
      SELECT 13;
    ELSE
      SELECT 15;
    END IF;
    EXECUTE 'SELECT ' || var2 || ' FROM information_schema.tables';
--    -- EXECUTE 'UPDATE tbl SET ' || quote_ident(colname) || ' = ' || quote_literal(newvalue) || ' WHERE key = ' || quote_literal(keyvalue);
    RETURN;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_simple( stmt text ) RETURNS VOID AS $$
  BEGIN
    SELECT pg_catalog.version();
    SELECT pg_catalog.version(stmt,found,3);

    SELECT 'foo'::text;

    SELECT usename,username FROM pg_user;
    EXECUTE 'SELECT ' || stmt || ' FROM information_schema.tables';
    INSERT INTO foo VALUES(stmt,2,3);
    INSERT INTO foo VALUES(1,2),(3,4);
    UPDATE foo SET bar = true;

    RETURN;
  END;
$$ LANGUAGE plpgsql;



