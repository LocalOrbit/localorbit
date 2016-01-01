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
                        <div style={{float: "right"}}>
                            <div className="widget-value" id="averageSalesAmount">
                                {this.props.avgSalesAmount}
                            </div>
                            <div className="widget-label">
                                Average Spend
                            </div>
                        </div>
                    </div>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <a href="/admin/orders"><span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View More ></span></a>
                    </div>
                </div>
            );        }
    });

    window.lo.sales_avg_amount_widget = sales_avg_amount_widget;
    module.exports = sales_avg_amount_widget;

}).call(this);
