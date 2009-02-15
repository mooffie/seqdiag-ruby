#!/usr/bin/ruby

require '../../seqdiag'

client = Model.new('client', 'Client')
v      = Model.new('v', '$view')
mod    = Model.new('mod', 'views.module')
admin  = Model.new('admin', 'View admin UI')
f      = Model.new('f', 'Filter')
q      = Model.new('q', '$views->query')

start_with(client) {
  fragment('scenarios') {

    line ''

    separator "Editing a filter"

    admin.User_uses_the_UI(:text => 'User uses the UI') {
      f.options_form() {
        f.show_operator_form() {
          f.operator_form() {
            line "$options = $this->operator_options()"
            line "$form['operator'] = array('#type' => 'radios', ...)"
            line "todo, add #default_value"
          }
        }
        #pop_levels 2
        f.show_value_form() {
          f.value_form() {
            line "$form['value'] = array()"
            line "todo, add #default_value"
          }
        }
      }
    }

    #
    # operators
    #
    line '_'
    note "TODO: I need to make this part clearer!", :right_of => f
    f.operator_options() {
      line "return array('=' => t('Is eual to'), ...)"
    }
    line '_'

    separator "Displaying the exposed filters form"

    v.build {
      line "$form_state['view'] = $this"
      mod.drupal_build_form("'views_exposed_form'", :return => "$this->exposed_filters") {
        line ''
        v.get_exposed_input(:return => "$form_state['input']", :ids => [98,99]) {
          note "Looks for input in $_GET\nor in $_SESSION"#, :right_of => v
        }
        line ''
        note "$form_state['input'] is\nlike $form_state['#post']", :right_of => v, :attach_to => 99

        f.exposed_form("$form, $form_state", :cond => '* [all filters]') {

          line "if (!$this->options['exposed']) return"
          line "if ($this->options['expose']['use_operator']) {"
          line "    $this->operator_form()"
          line "}"
          line "if ($this->options['expose']['indentifier']) {"
          line "    $this->value_form()"
          line "}"
          note "$form['operator'] and $form['value']\nare then moved into the \"right\"\nslots."
        }

        f.exposed_info(:cond => '* [all filters]', :return =>"$form['#info']"  )
        line "$form['#theme'] = ...views_exposed_form..."
      }

    }

    separator "Submitting the exposed filters form"

    v.build {
      line "$form_state['view'] = $this"
      mod.drupal_build_form('views_exposed_form', :return => "$this->exposed_filters") {
        line "It continues as in above;"
        line "..."
        line "..."
        line "..."
        line "but, finally:"
        fragment('opt', 'drupal detects the form was submitted') {
          mod.drupal_build_form_submit() {
            line "$view->exposed_data = $form_state['values']"
          }

        }
      }
      line '...'
      v._build('filters') {
        line ''
        fragment('opt', "$this->exposed_data exists") {
          line ''
          f.accept_exposed_input("$this->exposed_data", :cond => "* [all filters]" ) {
            line "$this->operator = $input[...]"
            line "$this->value = $input[...]"
          }
          f.store_exposed_input(:cond => "* [all filters]") {
            line "Store in $_SESSION"
          }
        }
        f.query(:cond => "* [all filters]" ) {
          q.add_where('\.\.\.')
        }
      }
    }

  }
}
