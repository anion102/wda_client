# encoding:utf-8
# author:anion
require 'selenium-webdriver'
module WdaClient
  module Ios
    DELAY_TIME = 3

    def search_element(opt)
      fail 'the request params opt can not be empty' if opt == {}
      template = WdaClient.element_template_operate(opt)
      # try 2 times to request search api
      for i in 0..1
        element= agent_post(@session_url+'/element/',template.to_json)
        if element == nil||element.class==String
          sleep DELAY_TIME
          next
        end
        if element['status']==0&&element['value']['ELEMENT']!=''
          break
        else
          sleep DELAY_TIME
        end
      end
      # catch exception
      # p element
      fail 'request search element api failed' if element==nil

      fail element['value'] if element['status']!=0
      fail 'unable to find the element on page' if element['value']['ELEMENT']==''||element['value']['ELEMENT']==nil

      # get element_id
      @element_id = element['value']['ELEMENT']
      @element_url = "#{@session_url}/element/#{@element_id}"
      @logger.info_log('wda_client::Element search_element',"search element with #{opt.values} succeed\n")

      return @element_id

    end


    def search_sub(opt)
      # try 3 times to request search api
      for i in 0..1
        element= agent_post(session_url+"/element/#{@element_id}/element",opt)
        if element==nil||element.match(/.*/)
          sleep DELAY_TIME
          next
        end
        if element['status']==0&&element['value']['ELEMENT']!=''
          break
        else
          sleep DELAY_TIME
        end
      end
      # catch exception
      fail 'request search element api failed' if element==nil

      fail 'find the sub element failed' if element['status']!=0
      fail 'unable to find the element sub on page' if element['value']['ELEMENT']==''||element['value']['ELEMENT']==nil
      # get element_id
      p element
=begin
      @element_id = element['value']['ELEMENT']
      return @element_id
=end
    end

    # get text of element
    # button or staticText =>label
    # other =>text
    def handle_get_text(opt)
      # get element
      find_element(opt)

      url = @session_url + "/element/#{@element_id}/text"
      text = agent_get(url)
      fail 'get text failed' unless text['status']==0
      return text['value']
    end

    # def get_attribute(arg)
    #   attribute = ['name','rect', 'size', 'location'] # 'enabled',, 'text', 'displayed', 'accessible'
    #   resp=Hash.new
    #   (attribute&arg).each do |attr|
    #     json =agent_get(@session_url + "/element/#{@element_id}/"+attr)
    #     resp[attr.to_sym]=json['']
    #   end
    # end

  end
end