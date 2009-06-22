
CREATE OR REPLACE FUNCTION vuln_sql_injection_direct( stmt text ) RETURNS VOID AS $$
  BEGIN
    EXECUTE 'SELECT now();';
    EXECUTE 'SELECT ' || stmt || ' FROM information_schema.tables';
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



