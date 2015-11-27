(function() {
    window.lo = window.lo || {};

    var dashboard = React.createClass({
        propTypes: {
            baseUrl: React.PropTypes.string.isRequired
        },

        getInitialState: function() {
            return {
                dashboard: []
            };
        },

        componentWillMount: function() {
            this.getData();
        },

        getData: function() {
            var self = this;
            $.getJSON(self.props.baseUrl + 'dashboards', function(res) {
                self.setState({dashboard: res.dashboard});
            });
        },

        render: function () {
            var self = this;

             return (
                 <div>
                     <div>
                         <div style={{float: 'left'}}>
                             <h1>Dashboard</h1>
                         </div>
                         <div style={{float: 'right'}}>
                             <lo.timeframe_picker />
                         </div>
                     </div>
                     <div className="row row--partial dashboard" style={{background: '#EEE', padding: 2}}>
                        <div className="column column--one-third" style={{background: '#FFF', marginRight: 1, padding: 2}}>
                            <lo.delivery_calendar_widget />
                        </div>
                        <div className="column column--one-third" style={{backgroundColor: '#FFF', marginRight: 1, padding: 2}}>
                            <lo.sales_amount_widget
                                totalSalesAmount={parseInt(self.state.dashboard.totalSalesAmount)}
                                totalSalesAmountGraph={self.state.dashboard.totalSalesAmountGraph}
                            />
                        </div>
                         <div className="column column--one-third" style={{backgroundColor: '#FFF', padding: 2}}>
                             <lo.sales_count_widget
                                 totalOrderCount={parseInt(self.state.dashboard.totalOrderCount)}
                                 totalOrderCountGraph={self.state.dashboard.totalOrderCountGraph}
                             />
                         </div>
                     </div>
                </div>
            );
        }
    });

    window.lo.dashboard = dashboard;
    module.exports = dashboard;

}).call(this);
