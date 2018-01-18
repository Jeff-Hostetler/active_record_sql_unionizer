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

  it "works with classes in module" do
    module SomeModule
      class Dummy < ActiveRecord::Base
        include ActiveRecordSqlUnionizer
      end
    end

    dummy_1 = SomeModule::Dummy.create!
    dummy_2 = SomeModule::Dummy.create!(name: "second")
    SomeModule::Dummy.create!(name: "not me")
    sql_string = "SELECT * FROM dummies WHERE name='second'"
    active_record_relation = SomeModule::Dummy.where(id: dummy_1.id)


    result = SomeModule::Dummy.unionize(sql_string, active_record_relation)


    expect(result).to be_kind_of(ActiveRecord::Relation)
    expect(result).to match_array([dummy_1, dummy_2])
  end

  it "can take a class method as an argument that returns relation or SQL string" do
    dummy_1 = Dummy.create!
    dummy_2 = Dummy.create!(name: "second")
    Dummy.create!(name: "not me")
    Dummy.singleton_class.class_eval do
      define_method(:some_scoping_method) do
        where(id: dummy_1.id)
      end
      define_method(:some_other_scoping_method) do
        "SELECT * FROM dummies WHERE name='second'"
      end
    end


    result = Dummy.unionize(:some_scoping_method, :some_other_scoping_method)


    expect(result).to be_kind_of(ActiveRecord::Relation)
    expect(result).to match_array([dummy_1, dummy_2])
  end

  it "raises when symbol passed in is not a class method" do
    expect {Dummy.unionize(:not_defined_class_method)}.to raise_error(
      "ActiveRecordSqlUnionizer expected Dummy to respond to not_defined_class_method, but it does not"
    )
  end

  it "raises when symbol passed in does not return relation or SQL string" do
    Dummy.singleton_class.class_eval do
      define_method(:some_scoping_method) do
        2
      end
    end


    expect {Dummy.unionize(:some_scoping_method)}.to raise_error(
      "ActiveRecordSqlUnionizer expected Dummy.some_scoping_method to return an ActiveRecord::Relation or SQL string, but it does not"
    )
  end

  it "raises when arg is not String, Symbol, or ActiveRecord::Relation" do
    expect {Dummy.unionize(2)}.to raise_error(
      "ActiveRecordSqlUnionizer received an arguement that was not a SQL string, ActiveRecord::Relation, or scoping method name"
    )
  end
end
