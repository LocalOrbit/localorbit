(function() {
    window.lo = window.lo || {};

    var sales_avg_amount_widget = React.createClass({
        propTypes: {
            avgSalesAmount: React.PropTypes.string
        },

        render: function () {
            var self = this;

            return (
                <div className="dashboard-widget small-widget">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="font-icon icon-money"></div>
                        </div>
                        <div style={{float: "right", paddingRight:10}}>
                            <div className="widget-value" id="averageSalesAmount">
                                {this.props.avgSalesAmount}
                            </div>
                            <div className="widget-label">
                                Avg Order Size
                            </div>
                        </div>
                    </div>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <a href="/admin/orders"><span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View Details ></span></a>
                        <span className="tooltip pull-right" data-tooltip="This number represents the average order size for the selected period.">&nbsp;</span>
                    </div>
                </div>
            );        }
    });

    window.lo.sales_avg_amount_widget = sales_avg_amount_widget;
    window.require = require;

}).call(this);
