const sql = require('mssql')

var sql_server = {

    query: function (sqlQuery, cb) {
        var conn = new sql.ConnectionPool(global.config.db);
        conn.connect().then(function () {
            var req = new sql.Request(conn);
            req.query(sqlQuery).then(function (recordset) {
                cb(null, recordset);
                //console.log(recordset);
                conn.close();
            })
            .catch(function (err) {
                cb(err, recordset);
                //console.log(err);
                conn.close();
            });        
        })
        .catch(function (err) {
            cb(err, null);
        });
    
    },

    storedProcedure : function (storedProcedure, params, cb) {
        var arr_params = [];
        
        if (params != "undefined" && params != null) {
            if(typeof params == "string"){
                arr_params = JSON.parse(params);
            }
            else{
                arr_params = params;
            }
        }

        var conn = new sql.ConnectionPool(global.config.db);
        
        conn.connect().then(function () {
        
            var req = new sql.Request(conn);

            for(var i = 0; i < arr_params.length; i++) {
                
                if(arr_params[i].direction == "input"){
                    req.input(arr_params[i].name, getSqlType(arr_params[i].type), arr_params[i].value);
                }
                else{
                    req.output(arr_params[i].name, getSqlType(arr_params[i].type));
                }
            }

            req.execute(storedProcedure).then(function (recordset) {
                cb(null, recordset);
                conn.close();
            })
            .catch(function (err) {
                cb(err, null);
                conn.close();
            });        
        })
        .catch(function (err) {
            cb(err, null);
        });

    }
    
};

function getSqlType(typeName)
{
    switch(typeName) {
        case 'sql.Bit':              return sql.Bit;
        case 'sql.BigInt':           return sql.BigInt;
        case 'sql.Decimal':          return sql.Decimal;
        case 'sql.Float':            return sql.Float;
        case 'sql.Int':              return sql.Int;
        case 'sql.Money':            return sql.Money;
        case 'sql.Numeric':          return sql.Numeric;
        case 'sql.SmallInt':         return sql.SmallInt ;
        case 'sql.SmallMoney':       return sql.SmallMoney;
        case 'sql.Real':             return sql.Real ;
        case 'sql.TinyInt':          return sql.TinyInt ;
        case 'sql.Char':             return sql.Char ;
        case 'sql.NChar':            return sql.NChar;
        case 'sql.Text':             return sql.Text ;
        case 'sql.NText':            return sql.NText;
        case 'sql.VarChar':          return sql.VarChar ;
        case 'sql.NVarChar':         return sql.NVarChar ;
        case 'sql.Time':             return sql.Time ;
        case 'sql.Date':             return sql.Date ;
        case 'sql.DateTime':         return sql.DateTime ;
        case 'sql.DateTime2':        return sql.DateTime2;
        case 'sql.DateTimeOffset':   return sql.DateTimeOffset;
        case 'sql.SmallDateTime':    return sql.SmallDateTime;
        case 'sql.UniqueIdentifier': return sql.UniqueIdentifier ;
        case 'sql.Binary':           return sql.Binary;
        case 'sql.VarBinary':        return sql.VarBinary;
        case 'sql.Image':            return sql.Image;
        case 'sql.UDT':              return sql.UDT ;
        case 'sql.Geography':        return sql.Geography;
        case 'sql.Geometry':         return sql.Geometry ;
        default:                     return sql.VarChar;
    }
}

module.exports = sql_server;
