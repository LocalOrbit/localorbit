(function() {
  window.lo = window.lo || {};

  var TemplatePicker = React.createClass({
    propTypes: {
      baseUrl: React.PropTypes.string.isRequired,
      cartUrl: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
      return {
        templates: []
      };
    },

    componentWillMount: function() {
      this.getTemplates();
    },

    getTemplates: function() {
      var self = this;
      $.getJSON(self.props.baseUrl + 'order_templates', function(res) {
        self.setState({templates: res.templates});
      });
    },

    addProduct: function(productId, quantity) {
      var deferred = Q.defer();
      $.ajax({
        url: this.props.cartUrl,
        type: 'PUT',
        data: {
          product_id: productId,
          quantity: quantity
        },
        success: deferred.resolve,
        error: deferred.reject
      });
      return deferred.promise;
    },

    applyTemplate: function(template) {
      var self = this;
      var promises = _.map(template.items, function(item) {
        return self.addProduct(item.product_id, item.quantity);
      });
      Q.all(promises)
        .done(function() {
          window.location = '/cart';
        });
    },

    render: function() {
      var self = this;
      var templates = _.map(self.state.templates, function(template) {
        return (
          <tr>
            <td>{template.name}</td>
            <td>
              <button className="btn btn--primary" onClick={self.applyTemplate.bind(this, template)}>Apply</button>
            </td>
          </tr>
        );
      });

      return (
        <div className="modal is-hidden" id="templatePicker" style={{background: "white", position: "fixed", padding: "20px", width: "50%", borderRadius: "5px"}}>
          <h1><i className="font-icon" data-icon=""></i>&nbsp; Order Templates</h1>
          <table>
            <thead>
              <tr>
                <th>Name</th>
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

  window.lo.TemplatePicker = TemplatePicker;
}).call(this);
