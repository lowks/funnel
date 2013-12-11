defmodule FilterRouterTest do
  use Funnel.TestCase, async: true
  use Dynamo.HTTP.Case

  @endpoint FilterRouter

  test "returns 400 when an empty body is given" do
    conn = post("/?token=token")
    assert conn.status == 400
  end

  test "returns 400 when an empty body is given on put" do
    conn = put("/uuid?token=token")
    assert conn.status == 400
  end

  test "returns json when an empty body is given" do
    body = '{"query" : {"term" : {"field1" : "value1"}}}'
    conn = conn(:POST, "/?token=token", body)
    conn = conn.put_req_header "Content-Type", "application/json"
    conn = post(conn, "/?token=token")
    assert conn.resp_headers["Content-Type"] == "application/json"
  end

  test "create a filter" do
    body = '{"query" : {"term" : {"field1" : "value1"}}}'
    conn = conn(:POST, "/?token=token")
    conn = conn.put_req_header "Content-Type", "application/json"
    conn = post(conn, "/?token=token", body)
    {:ok, body} = JSEX.decode conn.resp_body
    uuid = body["filter_id"]
    assert conn.status == 201
    Funnel.Es.unregister(uuid)
  end

  test "update a filter" do
    body = '{"query" : {"term" : {"field1" : "value1"}}}'
    conn = conn(:POST, "/?token=token")
    conn = conn.put_req_header "Content-Type", "application/json"
    conn = post(conn, "/?token=token", body)
    assert conn.status == 201
    {:ok, body} = JSEX.decode conn.resp_body
    uuid = body["filter_id"]
    body = '{"query" : {"term" : {"field1" : "value2"}}}'
    conn = conn(:PUT, "#{uuid}?token=token")
    conn = conn.put_req_header "Content-Type", "application/json"
    conn = put(conn, "#{uuid}?token=token", body)
    assert conn.status == 200
    Funnel.Es.unregister(uuid)
  end

  test "delete a existing filter" do
    body = '{"query" : {"term" : {"field1" : "value1"}}}'
    conn = conn(:POST, "/?token=token")
    conn = conn.put_req_header "Content-Type", "application/json"
    conn = post(conn, "/?token=token", body)
    assert conn.status == 201
    {:ok, body} = JSEX.decode conn.resp_body
    uuid = body["filter_id"]
    conn = conn(:PUT, uuid)
    conn = conn.put_req_header "Content-Type", "application/json"
    conn = delete(conn, "#{uuid}?token=token")
    assert conn.status == 200
  end

  test "delete a non-existing filter" do
    uuid = "uuid"
    conn = conn(:PUT, uuid)
    conn = conn.put_req_header "Content-Type", "application/json"
    conn = delete(conn, "#{uuid}?token=token")
    assert conn.status == 404
  end

  test "returns json" do
    body = '{"query" : {"term" : {"field1" : "value1"}}}'
    conn = conn(:POST, "/", body)
    conn = conn.put_req_header "Content-Type", "application/json"
    conn = post(conn, "/?token=token")
    assert conn.resp_headers["Content-Type"] == "application/json"
  end

  test "returns a filter_id" do
    body = '{"query" : {"term" : {"field1" : "value1"}}}'
    conn = conn(:POST, "/", body)
    conn = conn.put_req_header "Content-Type", "application/json"
    conn = post(conn, "/?token=token", body)
    {:ok, body} = JSEX.decode conn.resp_body
    assert size(body["filter_id"]) == 36
  end
end