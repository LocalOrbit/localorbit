(function() {
    window.lo = window.lo || {};

    //require('chart.js')

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

            var data1 = {
                labels: labels,
                series: [
                    data_points
                ]
            };

            var lineChartOptions = {
                low: 0,
                showArea: true
            };

            //var data1 = {
            //    labels: labels,
            //    datasets: [
            //        {
            //            label: "My First dataset",
            //            fillColor: "rgba(151,187,205,0.2)",
            //            strokeColor: "rgba(151,187,205,1)",
            //            pointColor: "rgba(151,187,205,1)",
            //            pointStrokeColor: "#fff",
            //           pointHighlightFill: "#fff",
            //            pointHighlightStroke: "rgba(151,187,205,1)",
            //            data: data_points
            //        }
            //    ]
            //};

            var data2 = {
                labels: ["1","2","3"],
                datasets: [
                    {
                        label: "My First dataset",
                        fillColor: "rgba(151,187,205,0.2)",
                        strokeColor: "rgba(151,187,205,1)",
                        pointColor: "rgba(151,187,205,1)",
                        pointStrokeColor: "#fff",
                        pointHighlightFill: "#fff",
                        pointHighlightStroke: "rgba(151,187,205,1)",
                        data: [20.34,10.05,30.56]
                    }
                ]
            };

            return (
                <div>
                    <div style={{fontSize: 36, textAlign: 'right'}}>
                        Total Sales
                    </div>
                    <div style={{fontSize: 24, textAlign: 'right'}}>
                        {this.props.totalSalesAmount}
                    </div>
                    <ChartistGraph data={data1} options={lineChartOptions} type={'Line'}/>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View More ></span>
                    </div>
                </div>
            )
        }
    });

    window.lo.sales_amount_widget = sales_amount_widget;
    module.exports = sales_amount_widget;

}).call(this);
