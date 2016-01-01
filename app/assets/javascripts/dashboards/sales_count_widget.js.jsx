(function() {
    window.lo = window.lo || {};

    const Plotly = require('react-plotlyjs');

    var sales_count_widget = React.createClass({
        propTypes: {
            totalOrderCount: React.PropTypes.number,
            totalOrderCountGraph: React.PropTypes.array
        },

        render: function () {

            var self = this;
            var labels=[], data_points=[];
            var j = this.props.totalOrderCountGraph;
            if (j) {
                $.each(j, function (i,v)
                {
                    labels.push(i);
                    data_points.push(parseFloat(v));
                });
            }

            let data = [
                {
                    type: 'bar',
                    x: labels,
                    y: data_points,
                    marker:{
                        color:"rgb(235, 235, 235)"
                    }
                }
            ];
            let layout = {
                autosize: true,
                width: 290,
                height: 300,
                margin: {
                    l: 5,
                    r: 5,
                    t: 20,
                    b: 25,
                    autoexpand: true
                },
                yaxis:{
                    type:"linear",
                    autorange:true,
                    showticklabels:false,
                    showgrid:false,
                    zeroline:false,
                    exponentformat:"none",
                    showexponent:"all"
                },
                xaxis:{
                    autorange:true,
                    showticklabels:false,
                    showgrid:false,
                    zeroline:false,
                    exponentformat:"none",
                    showexponent:"all"
                }
            };
            let config = {
                displayModeBar: false
            };

            return (
                <div className="dashboard-widget large-widget">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="font-icon icon-stack-checkmark"></div>
                        </div>
                        <div style={{float: "right"}}>
                            <div className="widget-value" id="totalOrderCount">
                                {this.props.totalOrderCount}
                            </div>
                            <div className="widget-label">
                                Total Orders
                            </div>
                        </div>
                        <div className="bottom-border"></div>
                    </div>
                    <Plotly className="SalesCount" data={data} layout={layout} config={config}/>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <a href="/admin/orders"><span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View More ></span></a>
                    </div>
                </div>
            );
        }
    });

    window.lo.sales_count_widget = sales_count_widget;
    module.exports = sales_count_widget;

}).call(this);
