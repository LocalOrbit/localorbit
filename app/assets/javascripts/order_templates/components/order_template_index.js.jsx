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
      var templates = _.map(self.state.templates, function(template) {
        return (
          <tr>
            <td>{template.name}</td>
            <td>{moment(template.created_at).format('L')}</td>
            <td>
              <a href className="btn">Edit</a>
              <a href="javascript:void(0);" onClick={self.deleteTemplate.bind(this, template.id)} className="pull-right" style={{marginTop:"9px"}}>Delete</a>
            </td>
          </tr>
        );
      });

      return (
        <div>
          <div className="sub-header stickable js-positioned">
          <div className="l-constraint">
            <div className="l-page-header admin-markets-header">
              <h1><i className="font-icon" data-icon=""></i>&nbsp; Order Templates</h1>
            </div>
          </div>
        </div>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Date Created</th>
                <th>Actions</th>
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
