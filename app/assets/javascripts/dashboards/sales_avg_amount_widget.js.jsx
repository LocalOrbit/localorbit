(function() {
    window.lo = window.lo || {};

    var sales_avg_amount_widget = React.createClass({
        propTypes: {
            avgSalesAmount: React.PropTypes.string.isRequired
        },

        render: function () {
            var self = this;

            return (
                <div className="dashboard-widget small-widget">
                    <div className="widget-value">
                        {this.props.avgSalesAmount}
                    </div>
                    <div className="widget-label">
                        Average Spend
                    </div>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View More ></span>
                    </div>
                </div>
            );        }
    });

    window.lo.sales_avg_amount_widget = sales_avg_amount_widget;
    module.exports = sales_avg_amount_widget;

}).call(this);
