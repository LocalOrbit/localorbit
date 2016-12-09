(function() {
  window.lo = window.lo || {};

  var OrderTemplateIndex = React.createClass({
    propTypes: {
      baseUrl: React.PropTypes.string.isRequired,
      templates: React.PropTypes.array.isRequired
    },

    getInitialState: function() {
      return {
        templates: this.props.templates
      };
    },

    getTemplates: function() {
      var self = this;
      $.getJSON(self.props.baseUrl, function(res) {
        self.setState({templates: res.templates});
      });
    },

    deleteTemplate: function(id) {
      $.ajax({
        url: this.props.baseUrl + id,
        type: 'DELETE',
        complete: this.getTemplates
      });
    },

    render: function() {
      var self = this;
      var questions_tool_tip = (<p style={{ marginTop:"2em" }} className="pull-right">Questions&nbsp;<span className="tooltip tooltip--crowded-top" data-tooltip="This is a list of all your Order Templates.  To create a new template, add items to the cart and go to checkout.  From the checkout page, click 'Create an Order Template from this Cart'"><i className="fa"></i></span></p>);
      //fa fa-question-circle
      var templates = _.map(self.state.templates, function(template) {
        return (
          <tr className="app-template">
            <td className="app-template-name">{template.name}</td>
            <td>{moment(template.created_at).format('L')}</td>
            <td>{moment(template.updated_at).format('L')}</td>
            <td>
              <a href="javascript:void(0);" onClick={self.deleteTemplate.bind(this, template.id)} className="pull-right app-delete-template">Delete</a>
            </td>
          </tr>
        );
      });

      return (
        <div>
          <div className="sub-header stickable js-positioned">
          <div className="l-constraint">
            <div className="l-page-header admin-markets-header">
              <h1><i className="font-icon" data-icon=""></i>&nbsp; Order Templates</h1>
              {questions_tool_tip}
            </div>
          </div>
        </div>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Date Created</th>
                <th>Date Modified</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {templates}
            </tbody>
          </table>
        </div>
      );
    }
  });

  window.lo.OrderTemplateIndex = OrderTemplateIndex;
}).call(this);
