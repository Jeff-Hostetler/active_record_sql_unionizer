require "spec_helper"
require_relative "../lib/active_record_sql_unionizer.rb"

describe "ActiveRecordSqlUnionizer" do
  class Dummy < ActiveRecord::Base
    include ActiveRecordSqlUnionizer
  end

  it "returns ActiveRecord relation that is union of relations and SQL queries" do
    dummy_1 = Dummy.create!
    dummy_2 = Dummy.create!(name: "second")
    Dummy.create!(name: "not me")
    sql_string = "SELECT * FROM dummies WHERE name='second'"
    active_record_relation = Dummy.where(id: dummy_1.id)


    result = Dummy.unionize(sql_string, active_record_relation)


    expect(result).to be_kind_of(ActiveRecord::Relation)
    expect(result).to match_array([dummy_1, dummy_2])
  end

  it "works with inherited classes" do
    class ChildDummy < Dummy
      include ActiveRecordSqlUnionizer
    end

    dummy_1 = ChildDummy.create!
    dummy_2 = ChildDummy.create!(name: "second")
    ChildDummy.create!(name: "not me")
    sql_string = "SELECT * FROM dummies WHERE name='second' AND type='ChildDummy'"
    active_record_relation = ChildDummy.where(id: dummy_1.id)


    result = ChildDummy.unionize(sql_string, active_record_relation)


    expect(result).to be_kind_of(ActiveRecord::Relation)
    expect(result).to match_array([dummy_1, dummy_2])

  end
end
