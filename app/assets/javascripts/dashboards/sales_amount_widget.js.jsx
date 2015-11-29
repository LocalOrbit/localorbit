(function() {
    window.lo = window.lo || {};

    const Plotly = require('react-plotlyjs');

    var sales_amount_widget = React.createClass({
        propTypes: {
            totalSalesAmount: React.PropTypes.string.isRequired,
            totalSalesAmountGraph: React.PropTypes.object.isRequired
        },

        render: function () {
            var self = this;
            var labels=[], data_points=[];
            var j = this.props.totalSalesAmountGraph;
            if (j) {
                $.each(j, function (i,v)
                {
                    labels.push(i > 0 ? i : 'None');
                    data_points.push(v > 0 ? parseFloat(v) : 'None');
                });
            }

            let data = [
                {
                    type: 'scatter',
                    x: labels,
                    y: data_points,
                    line:{
                        shape:"spline"
                    }
                }
            ];
            let layout = {
                autosize: true,
                width: 290,
                height: 400,
                margin: {
                    l: 5,
                    r: 5,
                    t: 20,
                    b: 35,
                    autoexpand: true
                },
                yaxis:{
                    autorange:true,
                    showticklabels:false,
                    showgrid:false,
                    zeroline:false
                },
                xaxis:{
                    autorange:true,
                    showticklabels:false,
                    showgrid:false,
                    zeroline:false
                }
            };
            let config = {
                displayModeBar: false
            };

            return (
                <div className="dashboard-widget large-widget">
                    <div className="widget-value">
                        {this.props.totalSalesAmount}
                    </div>
                    <div className="widget-label">
                        Total Spend
                    </div>
                    <Plotly className="SalesAmount" data={data} layout={layout} config={config}/>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View More ></span>
                    </div>
                </div>
            );        }
    });

    window.lo.sales_amount_widget = sales_amount_widget;
    module.exports = sales_amount_widget;

}).call(this);
