(function() {
  window.lo = window.lo || {};

  var ModifyCreditModal = React.createClass({
    propTypes: {
      baseUrl: React.PropTypes.string.isRequired,
      grossTotal: React.PropTypes.number.isRequired,
      amountTypes: React.PropTypes.array.isRequired,
      payerTypes: React.PropTypes.array.isRequired,
      sellers: React.PropTypes.array.isRequired,
      orderId: React.PropTypes.number.isRequired
    },

    getInitialState: function() {
      return {
        credit: (this.props.credit) ? this.props.credit : {
          id: null,
          amount_type: 'fixed',
          amount: null,
          payer_type: 'market',
          paying_org_id: null
        },
        loading: false,
        errors: false
      };
    },

    setAttributeValue: function(attribute, evt) {
      var credit = _.clone(this.state.credit, true);
      var value = evt.target.value;
      credit[attribute] = value;
      this.setState({credit: credit});
    },

    save: function() {
      var self = this;
      self.setState({loading: true, errors: false});
      $.ajax({
        url: self.props.baseUrl + 'orders/' + self.props.orderId + '/credits',
        method: 'POST',
        data: {
          credit: _.pick(self.state.credit, ['id', 'amount', 'payer_type', 'amount_type', 'paying_org_id', 'notes'])
        },
        success: function(res) {
          location.reload();
        },
        error: function(res) {
          var errors = JSON.parse(res.responseText).errors;
          self.setState({loading: false, errors: errors});
        }
      });
    },

    render: function() {
      var self = this;
      var credit = this.state.credit;
      var amountTypeOptions = _.map(self.props.amountTypes, function(type) {
        return (<option key={type} value={type}>{type[0].toUpperCase() + type.substring(1)}</option>);
      });

      var payerTypeOptions = _.map(self.props.payerTypes, function(type) {
        return (<option key={type} value={type}>{type[0].toUpperCase() + type.substring(1)}</option>);
      });

      if(credit.payer_type === 'supplier organization') {
        var sellerOptions = _.map(self.props.sellers, function(seller) {
          return (<option key={seller.id} value={seller.id}>{seller.name}</option>)
        });
        sellerOptions.unshift(<option key={null} value={null}>All</option>);
        var sellerSelect = (
          <div className='field'>
            <label>Supplier Organization</label><br/>
            <select defaultValue={credit.paying_org_id} onChange={self.setAttributeValue.bind(this, 'paying_org_id')} className='column--full'>
              {sellerOptions}
            </select>
          </div>
        );
      }
      else {
        var sellerOptions = null;
      }

      var errors = (self.state.errors) ? <p className='alert alert--warning'>{self.state.errors}</p> : null;

      return (
        <div id='creditEdit' className='popup modal is-hidden app-edit-credit-modal' style={{background: 'white', position: 'fixed', padding: '20px', width: '50%', borderRadius: '5px'}}>
          <h1>Modify Order Credit</h1>
          <div>
            {errors}
            <div className='row row--field'>
              <div className='field column column--half column--guttered'>
                <label>Type</label><br/>
                <select onChange={self.setAttributeValue.bind(this, 'amount_type')} defaultValue={credit.amount_type} name='amount-type'>
                  {amountTypeOptions}
                </select>
              </div>
              <div className='field column column--half column--guttered'>
                <label>Amount</label><br/>
                <input type='text' value={credit.amount} onChange={self.setAttributeValue.bind(this, 'amount')} name='amount'/>
              </div>
            </div>

            <div className='field'>
              <label>Credit Paid By</label><br/>
              <select defaultValue={credit.payer_type} onChange={self.setAttributeValue.bind(this, 'payer_type')} className='column--full'>
                {payerTypeOptions}
              </select>
            </div>

            {sellerSelect}

            <div className='row row--field'>
              <label>Notes (Optional)</label>
              <textarea name='notes' value={credit.notes} onChange={self.setAttributeValue.bind(this, 'notes')} className='column--full'/>
            </div>
            <div className='row'>
              <button className='btn pull-right' style={{marginLeft: '20px', float: 'right', display: "inline-block", padding: "6px 14px", border: "solid 1px #a6a6a6", borderRadius: "5px", background: "#a6a6a6", color: "#ffffff", fontSize: "16px", textAlign: "center"}} className="close" onClick={self.cancel}>Cancel</button>
              <button onClick={self.save} className='btn btn--primary pull-right app-save-credit'>Save</button>
            </div>
          </div>
        </div>
      );
    }
  });

  window.lo.ModifyCreditModal = ModifyCreditModal;
}).call(this);
