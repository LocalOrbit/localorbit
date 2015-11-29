//= require product_catalog/mixins/product_row_mixin.js

(function() {

  var MobileProductRow = React.createClass({
    mixins: [window.lo.ProductRowMixin],

    tabs: [
      {label: (<a href="javascript:void(0)"><i className="font-icon icon-credit"></i> About</a>), key: "about"},
      {label: (<a href="javascript:void(0)"><i className="font-icon icon-credit"></i> Who</a>), key: "who"},
      {label: (<a href="javascript:void(0)"><i className="font-icon icon-archive"></i> How</a>), key: "how"},
      {label: (<a href="javascript:void(0)"><i className="font-icon icon-direction"></i> Where</a>), key: "where"}
    ],

    tabContent: function() {
      var gp = this.props.product;
      return {
        about: (
          <div style={{marginTop:"5px", float:"left"}}>
            <img style={{width:"100%", borderRadius:"4px"}} src={gp.image_url}/>
            <p>{gp.short_description}</p>
          </div>
        ),
        who: (
          <div style={{marginTop:"5px", float:"left"}}>
            <p>{gp.who_story}</p>
          </div>
        ),
        how: (
          <div style={{marginTop:"5px", float:"left"}}>
            <p>{gp.how_story}</p>
          </div>
        ),
        where: (
          <div style={{marginTop:"5px", float:"left"}}>
            <h4 style={{marginTop: "0px"}}>{gp.location_label}</h4>
            <img className="location-map" alt="" src={gp.location_map_url}/>
          </div>
        )
      };
    },

    getInitialState: function() {
      return {
        selectedTab: "about",
        showInfo: false
      };
    },

    infoClickHandler: function() {
      this.setState({showInfo: !this.state.showInfo});
    },

    tabClickHandler: function(key) {
      this.setState({selectedTab: key});
    },

    generateInfo: function() {
      var self = this;
      if(!self.state.showInfo) return;

      var content = self.tabContent()[self.state.selectedTab];
      var tabs = _.map(self.tabs, function(tab) {
        var className = (self.state.selectedTab === tab.key) ? "active" : null;
        return (<li onClick={self.tabClickHandler.bind(this, tab.key)} className={className}>{tab.label}</li>)
      });
      return (
        <div className="product-details-mobile pull-left">
          <ul>{tabs}</ul>
          {content}
        </div>
      );
    },

    render: function() {
      var gp = this.props.product;
      var unitPrices = _.map(gp.available, function(p) {
        return <lo.MobileProductUnitPrices key={p.id} product={p} />
      });

      var inputs = _.map(gp.available, function(p) {
        return <lo.MobileProductInput key={p.id} product={p} />
      });

      var info = this.generateInfo();

      return (
        <div className="row product-listing mobile">
          <div className="product-listing-header">
            <div className="column--three-fourths pull-left">
              <h3><a href={"/products/" + gp.id}>{gp.name}</a></h3>
              <h5>From: <span style={{fontStyle: "italic"}}>{gp.seller_name}</span></h5>
            </div>
            <div className="column--fourth pull-left">
              <a className="btn btn--info btn--small pull-right" style={{padding: "4px 10px", fontSize: "14px", color: "#0C2F87"}} onClick={this.infoClickHandler}><i className="font-icon icon-plus-circle"></i> Info</a>
            </div>
          </div>
          <div style={{clear: "both"}}></div>
          {info}
          <div style={{clear: "both"}}></div>
          <div style={{marginTop: "26px"}}>
            <table className="pricing-table-mobile">
              <thead>
                <tr>
                    <th colSpan="4">
                    PRICING PER UNIT
                    </th>
                </tr>
              </thead>
                {unitPrices}
            </table>
            <br/>
          </div>
          {inputs}
          <div style={{clear:"both"}}></div>
        </div>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.MobileProductRow = MobileProductRow;
}).call(this);
