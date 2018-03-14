package myfoodmart;

import mondrian.rolap.SqlStatement;

import java.sql.*;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

public class ClickHouseDialect extends JdbcDialectImpl {
  public static final JdbcDialectFactory FACTORY =
      new JdbcDialectFactory(
          ClickHouseDialect.class,
          null)
      {
        protected boolean acceptsConnection(Connection connection) {
          // Greenplum looks a lot like Postgres. If this is a
          // Greenplum connection, yield to the Greenplum dialect.
          return super.acceptsConnection(connection)
              && !isDatabase(DatabaseProduct.GREENPLUM, connection)
              && !isDatabase(DatabaseProduct.NETEZZA, connection)
              && !isDatabase(DatabaseProduct.REDSHIFT, connection);
        }
      };

  public ClickHouseDialect(Connection connection) throws SQLException {
    super(connection);
  }

  public DatabaseProduct getDatabaseProduct() {
    return DatabaseProduct.POSTGRESQL;
  }

  @Override
  public boolean allowsRegularExpressionInWhereClause() {
    return true;
  }

  public String generateRegularExpression(String source, String javaRegex) {
    try {
      Pattern.compile(javaRegex);
    } catch (PatternSyntaxException e) {
      // Not a valid Java regex. Too risky to continue.
      return null;
    }
    javaRegex = javaRegex.replace("\\Q", "");
    javaRegex = javaRegex.replace("\\E", "");
    final StringBuilder sb = new StringBuilder();
    sb.append("cast(");
    sb.append(source);
    sb.append(" as text) ~ ");
    quoteStringLiteral(sb, javaRegex);
    return sb.toString();
  }

  @Override
  public SqlStatement.Type getType(
      ResultSetMetaData metaData, int columnIndex)
      throws SQLException
  {
    final int precision = metaData.getPrecision(columnIndex + 1);
    final int scale = metaData.getScale(columnIndex + 1);
    final int columnType = metaData.getColumnType(columnIndex + 1);
    final String columnName = metaData.getColumnName(columnIndex + 1);

    //  TODO - Do we need the check for "m"??
    if (columnType == Types.NUMERIC
        && scale == 0 && precision == 0
        && columnName.startsWith("m"))
    {
      // In Greenplum  NUMBER/NUMERIC w/ no precision or
      // scale means floating point.
      logTypeInfo(metaData, columnIndex, SqlStatement.Type.OBJECT);
      return SqlStatement.Type.OBJECT; // TODO - can this be DOUBLE?
    }
    return super.getType(metaData, columnIndex);
  }

}

// End PostgreSqlDialect.java