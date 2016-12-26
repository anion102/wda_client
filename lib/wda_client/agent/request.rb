# encoding:utf-8
# author:anion
# date:2016/12/21

require 'net/http'
require 'uri'
require 'uri/generic'
require 'json'

module WdaClient
  module Agent

    # data json
    # post--WebDriverAgent using
    def agent_post *args
      begin
        uri = URI.parse args[0]
        req = Net::HTTP::Post.new(uri.request_uri,{'Content-Type'=> 'application/json'})
        req.body = args[1]
        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end
        return JSON.parse(res.body)
      rescue Exception=>e
        return e.message
      end
    end

    def delete *args
      begin
        uri = URI.parse args[0]
        req = Net::HTTP::Delete.new(uri.request_uri,{'Content-Type'=> 'application/json'})
        req.body = args[1]
        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end
        return JSON.parse(res.body)
      rescue Exception=>e
        return e.message
      end
    end

    #data form post
    def post_form *args
      uri = URI.parse(args[0])
      http = Net::HTTP.new(uri.host,uri.port)
      req = Net::HTTP::Post.new(uri.path,args[2])
      req.set_form_data args[1]
      res = http.request(req)
      return JSON.parse(res.body)
    end

    # data form get
    def get_form_with_header *args
      uri = URI.parse(args[0])
      http = Net::HTTP.new(uri.host,uri.port)
      req = Net::HTTP::Get.new(uri.path,args[2])
      req.set_form_data args[1]
      res = http.request(req)
      return JSON.parse(res.body)
    end

    #get请求 请求包是表单格式 text/html;charset=UTF-8
    def get_form *args
      uri = URI.parse(args[0])
      uri.query=URI.encode_www_form(args[1])
      res = Net::HTTP.get_response(uri)
      begin
        return JSON.parse(res.body)
      rescue Exception=>e
        puts e.message
      end
    end

    # url get
    def agent_get url
      begin
        uri = URI(url)
        response = Net::HTTP.get_response(uri)
        return JSON.parse(response.body)
      rescue Exception=>e
        return e.message
      end
    end
  end
end

