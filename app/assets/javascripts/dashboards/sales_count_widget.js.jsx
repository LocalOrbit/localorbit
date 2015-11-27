(function() {
    window.lo = window.lo || {};

    const Plotly = require('react-plotlyjs');

    var sales_count_widget = React.createClass({
        propTypes: {
            totalOrderCount: React.PropTypes.number.isRequired,
            totalOrderCountGraph: React.PropTypes.object.isRequired
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
                    type: 'bar',      // all "bar" chart attributes: #bar
                    x: labels,     // more about "x": #bar-x
                    y: data_points    // #bar-y
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
                    b: 25,
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
                        {this.props.totalOrderCount}
                    </div>
                    <div style={{fontSize: 24, textAlign: 'right'}}>
                        Total Count
                    </div>
                    <Plotly className="SalesCount" data={data} layout={layout} config={config}/>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View More ></span>
                    </div>
                </div>
            );
        }
    });

    window.lo.sales_count_widget = sales_count_widget;
    module.exports = sales_count_widget;

}).call(this);
