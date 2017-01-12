# encoding:utf-8
# author:anion
require 'selenium-webdriver'
module WdaClient
  module Ios
    DELAY_TIME = 3
    def self.handle_request_data(from_x,from_y,to_x,to_y,duration)
      opt = Hash.new
      opt[:fromX] = from_x.to_f
      opt[:fromY] = from_y.to_f
      opt[:toX] = to_x.to_f
      opt[:toY] = to_y.to_f
      opt[:duration] = duration
      return opt
    end
    def search_element(opt)
      fail 'the request params opt can not be empty' if opt == {}
      template = WdaClient.element_template_operate(opt)
      # p template.to_json
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
      search_element(opt)

      url = @session_url + "/element/#{@element_id}/text"
      text = agent_get(url)
      fail 'get text failed' unless text['status']==0
      return text['value']
    end

    # location drag
    def handle_drag(from_x,from_y,to_x,to_y,duration)
      request = WdaClient::Ios.handle_request_data(from_x,from_y,to_x,to_y,duration)
      # operate
      # p request.to_json
      drag = agent_post(@session_url+'/uiaTarget/dragfromtoforduration/',request.to_json)
      delay_while(0.3)
      fail 'handle_drag:102 : page draging failed' unless drag['status']==0
    end

    # use Coordinate to click
    # element==nil stand for coordinate start (0,0)
    # or take element as the center
    def handle_tap(x,y,element)
      req={x: x, y: y}
      # p req.to_json
      tap = agent_post(@session_url+"/tap/#{element}",req.to_json)
      # p tap
      fail 'handle_tap:113 : tap failed' unless tap['status']==0
      return tap

    end

    # take element to another coordinate
    def handle_scroll(opt)

    end

  end
end