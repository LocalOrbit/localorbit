(function() {
    window.lo = window.lo || {};

    const Plotly = require('react-plotlyjs');

    var sales_count_widget = React.createClass({
        propTypes: {
            totalOrderCount: React.PropTypes.number,
            totalOrderCountGraph: React.PropTypes.array,
            lineColor: React.PropTypes.string,
            fillColor: React.PropTypes.string,
            axisTitle: React.PropTypes.string
        },

        render: function () {

            var self = this;
            var labels=[], data_points=[];
            var j = this.props.totalOrderCountGraph;
            var lineColor = this.props.lineColor;
            var fillColor = this.props.fillColor;
            var axisTitle = this.props.axisTitle;
            var totalOrderCount;
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
                        color: fillColor
                    },
                    fillcolor: fillColor
                }
            ];
            let layout = {
                autosize: true,
                width: 290,
                height: 300,
                margin: {
                    l: 25,
                    r: 15,
                    t: 20,
                    b: 40,
                    autoexpand: true
                },
                yaxis:{
                    autorange: true,
                    zeroline:false,
                    showgrid:false,
                    autotick: false,
                    rangemode: 'range',
                    range: [1,],
                    type:"linear",
                    dtick: 1
                },
                xaxis:{
                    autorange: true,
                    showgrid:false,
                    zeroline:false,
                    autotick: false,
                    title: axisTitle,
                    tickmode: 'linear',
                    rangemode: 'range',
                    range: [1,],
                    dtick: 1,
                    tick0: 1
                }
            };
            let config = {
                displayModeBar: false
            };

            if (this.props.totalOrderCount)
                totalOrderCount = this.props.totalOrderCount;
            else
                totalOrderCount = '0';

            return (
                <div className="dashboard-widget large-widget">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="font-icon icon-stack-checkmark"></div>
                        </div>
                        <div style={{float: "right"}}>
                            <div className="widget-value" id="totalOrderCount">
                                {totalOrderCount}
                            </div>
                            <div className="widget-label">
                                Orders Created
                            </div>
                        </div>
                        <div className="bottom-border"></div>
                    </div>
                    <Plotly className="SalesCount" data={data} layout={layout} config={config}/>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <a href="/admin/orders"><span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View Details ></span></a>
                    </div>
                </div>
            );
        }
    });

    window.lo.sales_count_widget = sales_count_widget;
    window.require = require;

}).call(this);
