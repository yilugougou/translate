# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_12_15_092552) do

  create_table "fetch_rules", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "后台的抓取排名的规则表", force: :cascade do |t|
    t.integer "market_id", comment: "渠道id, 例如：360市场"
    t.integer "market_module_id", comment: "资源位id, 例如：排行榜"
    t.text "url", comment: "要抓取的接口的url，例如： http://www.360.cn/interface/ranking.json"
    t.string "run_at", comment: "运行的间隔，例如： \"every 1d\", \"0 12 * * * \""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "code"
    t.string "http_method"
    t.text "code_to_find_items", comment: "找到竞品的列表的代码,例如: parsed_body['data']['category']"
    t.string "code_to_find_single_item"
    t.text "headers", comment: "放User-Agent, Content-Type等Header 参数"
    t.text "code_of_request_body", comment: "发起post, put等请求时会用到"
    t.text "code_to_get_response", comment: "获得response的代码. 它是对于fetcher#get_reponse方法的重写"
  end

  create_table "translations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "input_text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
