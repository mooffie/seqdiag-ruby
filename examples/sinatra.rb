#!/usr/bin/ruby

require '../seqdiag'

administrator = Model.new('admin', 'Administrator', :flags => 'pe')
base = Model.new('base', 'MyApp < Sinatra::Base')
inst = Model.new('inst', 'MyApp instance', :needs_new => true)
server = Model.new('server', 'Rack server handler', :needs_new => true, :flags => 'rx')
browser = Model.new('browser', 'Web browser')
human = Model.new('human', 'Human', :flags => 'pe')

start_with(administrator) {
  base.run! {
    server.new
    server.run(' self ')
  }
}

start_with(human) {
  browser.visit_page(:text => 'user visits a page') {
    server.invoke(:text => 'request') {
      base.call {

        fragment('alt', 'There\'s no input for this argument') {
          base.New
          line "build middleware"
          inst.new(:return => '@prototype')
        }

        inst.call {
          inst.invoke {
            inst.dispatch! {
              inst.route! {
                line "// figures out the block to call"
                inst.route_eval('&block') {
                  line "throw :halt, instance_eval(&block)"
                }
              }
              line "If exception was caught, set @response.status"
              line "and return the value of the error handler."
            }
            line "catches the :halt"
            line "turns the block's returned value"
            line "into a @response object" 
          }
        }

      }
    }
  }
}
