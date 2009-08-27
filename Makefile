
PREFIX=/home/sven/diplom/local/

all: xml
		ruby analyze.rb

install_functions: test.sql
		${PREFIX}bin/psql -t -q < test.sql

xml: install_functions
		${PREFIX}bin/psql -A -t -q -c "SELECT dump_plpgsql_function('vuln_sql_injection_direct(text)'::regprocedure);" | xsltproc ../rama/plpgsql_function.xsl - > vuln_sql_injection_direct.xml
