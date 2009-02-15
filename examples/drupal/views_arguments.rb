#!/usr/bin/ruby

require '../../seqdiag'

client = Model.new('client', '_build_arguments()')
a = Model.new('a', 'Argument')
d = Model.new('d', 'ArgumentDefault', :needs_new => true, :flags => 'rx')
v = Model.new('v', 'ArgumentValidator', :needs_new => true, :flags => 'rx')
q = Model.new('q', '$view->query')

start_with(client) {
  fragment('Loop', 'over all arguments') {

    fragment('alt', 'There\'s no input for this argument') {
      line ''
      a.has_default_argument(:return => 'has_default')
      line ''
      a.get_default_argument(:cond => '[has_default]', :return => '$arg') {
        d.new(" $this->options['default_argument_type'] ")
        d.get_argument(:return => '$arg')
      }
      line ''
    }

    fragment('alt', 'There\'s input, $arg, for this argument') {
      line ''
      a.set_argument('$arg', :return => 'validated') {
        a.validate_arg(:return => ' ')
        v.new(" $this->options['validate_type'] ")
        v.validate_argument(:return => 'validated')
      }
      line ''
      a.validate_fail(:cond => '[not validated]') {
        line "default_action( $this->options['validate_fail_action'] )"
        note "break loop"
      }
      a.query(:cond => '[validated]') {
        q.add_where
      }

      separator "[There's no input for this argument]"

      line ''
      a.default_action(" $this->options['default_action'] ") {
        fragment('alt') {

          separator '"Display all values"'
          line 'Do Nothing'

          separator '"Page not found"'
          line "$this->view->build_info['fail'] = TRUE;"

          separator '"Empty"'
          line "$this->view->built = TRUE;"
          line "$this->view->executed = TRUE;"
          line "$this->view->result = array();"

          separator '"Summary"'
          line "$this->view->plugin_name = $this->options['style_plugin'];"
          line "$this->view->style_options = $this->options['style_options'];"
          q.clear_fields()
          q.add_field('$this->real_field')
          q.add_groupby('$this->name_field')
          q.set_count_field('$this->real_field')
        }
      }
      line '_'
      note 'break loop'
      line '_'
    }

  }
}
