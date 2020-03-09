DECLARE @TABLE_NAME SYSNAME= 'customer';

DECLARE @sql NVARCHAR(MAX)= ' DECLARE ';
DECLARE @CAMPOS NVARCHAR(MAX)
declare @campossintipo nvarchar(max)
SELECT @CAMPOS=
(
    SELECT STRING_AGG('@' + COLUMN_NAME + ' ' + DATA_TYPE + CASE
                                                                WHEN CHARACTER_MAXIMUM_LENGTH IS NULL
                                                                THEN ''
                                                                ELSE '(' + CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR) + ')'
                                                            END, ',') AS COL
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TABLE_NAME and COLUMN_NAME not like '$%'
) +';',
@campossintipo= (
    SELECT STRING_AGG('@' + COLUMN_NAME + ' ' , ',') AS COL
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TABLE_NAME and COLUMN_NAME not like '$%'
) +'';
SELECT @SQL =  @sql + @CAMPOS + CHAR(10)+CHAR(13) + '; DECLARE @SQL nvarchar(max)='' SELECT * FROM ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = @TABLE_NAME;
SELECT @SQL=@sql+ CHAR(10)+CHAR(13)+ ' WHERE 1=1 '
SELECT @SQL=@SQL +CHAR(10)+CHAR(13)+ ' /*< @' +COLUMN_NAME +'> */  AND '+QUOTENAME(COLUMN_NAME)+'=@'+COLUMN_NAME +' /*</@' +COLUMN_NAME +'> */ '
FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TABLE_NAME and COLUMN_NAME not like '$%'
SELECT @SQL=@SQL+'''';

SELECT @SQL=@SQL +CHAR(10)+CHAR(13)+ 'if @' + column_name +  ' is null  
			begin 
			  select @sql=replace(@sql,''/*< @' +COLUMN_NAME +'> */'', ''/*/*< @' +COLUMN_NAME +'> */'') 
			  select @sql=replace(@sql,''/*</@' +COLUMN_NAME +'> */'', ''/*< @' +COLUMN_NAME +'> */*/'')
			end '
FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TABLE_NAME and COLUMN_NAME not like '$%'




SELECT @SQL=@SQL + ' exec sp_executesql @sql,'+'N'''+replace(@CAMPOS,';','')+''','+@campossintipo
SELECT @sql