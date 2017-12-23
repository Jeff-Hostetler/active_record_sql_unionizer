# Purpose
Give an extension for your active record classes that allows union queries. The queries can be active record relations
 or SQL strings so that you have some flexibility around how you write your queries. 
 
# How use
Include in your project

```apple js
gem "active_record_sql_unionizer"
```

```apple js
gem install active_record_sql_unionizer
```

Bring ActiveRecordSqlUnionizer into your active record class.

```apple js
class Dummy < ActiveRecord::Base
  include ActiveRecordSqlUnionizer
end
```

You are then free to call
```apple js
result = Dummy.unionize(sql_string, active_record_relation)
``` 

The `unionize` method takes any amount of ActiveRecord::Relation or valid SQL strings. 

# If you fork

### Setup Test Database
Currently just tested with postgres. Source 'TEST_DB' as the test database you want to use or create the test db in irb;
```apple js
require 'pg'
conn = PG.connect(dbname: 'postgres')
conn.exec("CREATE DATABASE unionizer_test")
```
