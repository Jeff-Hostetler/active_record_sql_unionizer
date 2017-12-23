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
end
