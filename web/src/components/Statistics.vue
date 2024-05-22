<template>
    <div class="container">
        <h1 class="title">统计</h1>

        <!-- 每日销售额 -->
        <div class="statistics-group">
            <h2 class="statistics-title">每日销售额</h2>
            <p class="statistics-data">{{ dailySales.totalSales }}</p>
        </div>

        <!-- 每月销售额 -->
        <div class="statistics-group">
            <h2 class="statistics-title">每月销售额</h2>
            <p class="statistics-data">{{ monthlySales.totalSales }}</p>
        </div>

        <!-- 每年销售额 -->
        <div class="statistics-group">
            <h2 class="statistics-title">每年销售额</h2>
            <p class="statistics-data">{{ yearlySales.totalSales }}</p>
        </div>

        <!-- 总支出 -->
        <div class="statistics-group">
            <h2 class="statistics-title">总支出</h2>
            <p class="statistics-data">员工: {{ totalExpense.staffExpense }}</p>
            <p class="statistics-data">进货: {{ totalExpense.productExpense }}</p>
        </div>

        <!-- 总收入 -->
        <div class="statistics-group">
            <h2 class="statistics-title">总收入</h2>
            <p class="statistics-data">{{ totalIncome.income }}</p>
        </div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    name: 'Statistics',
    data() {
        return {
            dailySales: {},
            monthlySales: {},
            yearlySales: {},
            totalExpense: {},
            totalIncome: {}
        }
    },
    created() {
        axios.get('/api/statistics/sales/daily')
            .then(response => {
                this.dailySales = response.data;
            });
        axios.get('/api/statistics/sales/monthly')
            .then(response => {
                this.monthlySales = response.data;
            });
        axios.get('/api/statistics/sales/yearly')
            .then(response => {
                this.yearlySales = response.data;
            });
        axios.get('/api/statistics/expense')
            .then(response => {
                const expense = (response.data == null ? {staffExpense: 0,productExpense: 0} : response.data);
                this.totalExpense = expense;
            });
        axios.get('/api/statistics/income')
            .then(response => {
                const income = (response.data == null ? 0 : response.data);
                this.totalIncome = income;
            });
    }
}
</script>

<style scoped>
.container {
    width: 80%;
    margin: auto;
    font-family: 'Roboto', sans-serif;
}

.title {
    text-align: center;
    color: #3F51B5;
    margin-bottom: 40px;
}

.statistics-group {
    background-color: #E8EAF6;
    padding: 20px;
    margin-bottom: 20px;
    border-radius: 4px;
    box-shadow: 0px 2px 4px -1px rgba(0,0,0,0.2), 0px 4px 5px 0px rgba(0,0,0,0.14), 0px 1px 10px 0px rgba(0,0,0,0.12);
}

.statistics-title {
    color: #3F51B5;
    margin-bottom: 10px;
}

.statistics-data {
    color: #1A237E;
    font-weight: bold;
}
</style>
