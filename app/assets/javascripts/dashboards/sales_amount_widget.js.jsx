(function() {
    window.lo = window.lo || {};

    const Plotly = require('react-plotlyjs');

    var sales_amount_widget = React.createClass({
        propTypes: {
            userType: React.PropTypes.string,
            totalSalesAmount: React.PropTypes.string,
            totalSalesAmountGraph: React.PropTypes.array
        },

        render: function () {
            var self = this;
            var label_text;
            var labels=[], data_points=[];
            var j = this.props.totalSalesAmountGraph;
            if (j) {
                $.each(j, function (i,v)
                {
                    //labels.push(i > 0 ? i : 'None');
                    //data_points.push(v > 0 ? parseFloat(v) : 'None');
                    labels.push(i);
                    data_points.push(parseFloat(v));
                });
            }

            let data = [
                {
                    type: 'scatter',
                    x: labels,
                    y: data_points,
                    line:{
                        shape:"spline"
                    },
                    marker:{
                        color:"rgb(235, 235, 235)"
                    },
                    //fill:"tonexty",
                    mode:"lines+markers",
                    uid:"ab9b77",
                    connectgaps:false,
                    fillcolor:"rgb(204, 204, 204)"
                }
            ];
            let layout = {
                autosize: true,
                width: 290,
                height: 300,
                margin: {
                    l: 40,
                    r: 5,
                    t: 20,
                    b: 35,
                    autoexpand: true
                },
                yaxis:{
                    autorange:true,
                    showticklabels:true,
                    showgrid:false,
                    zeroline:false,
                    exponentformat:"B",
                    showexponent:"all",
                    tickprefix:"$",
                    tickfont:{
                        size:10
                    }
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

            if (this.props.userType == "S" || this.props.userType == "M")
                label_text = 'Total Sales';
            else
                label_text = 'Total Spend';

            return (
                <div className="dashboard-widget large-widget">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="font-icon icon-coins"></div>
                        </div>
                        <div style={{float: "right"}}>
                            <div className="widget-value" id="totalSalesAmount">
                                {this.props.totalSalesAmount}
                            </div>
                            <div className="widget-label">
                                {label_text}
                            </div>
                        </div>
                        <div className="bottom-border"></div>
                    </div>
                    <Plotly className="SalesAmount" data={data} layout={layout} config={config}/>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <a href="/admin/orders"><span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View More ></span></a>
                    </div>
                </div>
            );        }
    });

    window.lo.sales_amount_widget = sales_amount_widget;
    module.exports = sales_amount_widget;

}).call(this);
