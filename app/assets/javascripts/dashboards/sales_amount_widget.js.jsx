(function() {
    window.lo = window.lo || {};

    const Plotly = require('react-plotlyjs');

    var sales_amount_widget = React.createClass({
        propTypes: {
            totalSalesAmount: React.PropTypes.number.isRequired,
            totalSalesAmountGraph: React.PropTypes.object.isRequired
        },

        render: function () {
            var self = this;
            var labels=[], data_points=[];
            var j = this.props.totalSalesAmountGraph;
            if (j) {
                $.each(j, function (i,v)
                {
                    labels.push(i);
                    data_points.push(parseFloat(v));
                });
            }

            let data = [
                {
                    type: 'scatter',
                    fill: 'tozeroy',
                    x: labels,
                    y: data_points,
                    line:{
                        shape:"spline"
                    }
                }
            ];
            let layout = {
                autosize: true,
                width: 300,
                height: 400,
                margin: {
                    l: 15,
                    r: 15,
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
                <div>
                    <div style={{fontSize: 36, textAlign: 'right'}}>
                        {this.props.totalSalesAmount}
                    </div>
                    <div style={{fontSize: 24, textAlign: 'right'}}>
                        Total Count
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
