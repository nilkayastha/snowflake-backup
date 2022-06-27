CREATE OR REPLACE PROCEDURE "ALT_COLUMN"()
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sqlGetTable = `SELECT TGT_FILE_TBL FROM iip_abc.ABC_JOB_CTRL_TBL where JOB_TYP_CD = ''PRC'';`;
var sqlStmt = snowflake.createStatement({sqlText: sqlGetTable});
var resultScan = sqlStmt.execute();
while (resultScan.next())
{   
    var tblName = resultScan.getColumnValue(1);
    var sqlAlterTable = `call PRCREATEVIEW (''EYIIP_DEMO'',''IIP_PRCS_DEV'',''${tblName}'');`;
    var sqlStmt2 = snowflake.createStatement({sqlText: sqlAlterTable});
    return sqlAlterTable;
    //sqlStmt2.execute();
}
';