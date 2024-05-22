<template>
    <div class="container">
        <h1 class="title">售出</h1>

        <!-- 添加新售出的表单 -->
        <div class="form-group">
            <input v-model="newSale.productID" placeholder="产品ID" class="form-control" />
            <input v-model="newSale.saleTime" placeholder="售出时间" class="form-control" />
            <input v-model="newSale.actualUnitPrice" placeholder="实际单价" class="form-control" />
            <input v-model="newSale.soldQuantity" placeholder="售出数量" class="form-control" />
            <input v-model="newSale.memberID" placeholder="会员ID" class="form-control" />
            <button @click="insertSales(newSale)" class="btn btn-success">添加售出记录</button>
        </div>

        <!-- 显示售出信息的表格 -->
        <table class="table">
            <tr>
                <th>产品ID</th>
                <th>售出时间</th>
                <th>实际单价</th>
                <th>售出数量</th>
                <th>会员ID</th>
                <th>操作</th>
            </tr>
            <tr v-for="sale in sales" :key="sale.salesID">
                <td>{{ sale.productID }}</td>
                <td>{{ sale.saleTime }}</td>
                <td>{{ sale.actualUnitPrice }}</td>
                <td>{{ sale.soldQuantity }}</td>
                <td>{{ sale.memberID }}</td>
                <td>
                    <div class="btn-group">
                        <button class="btn btn-primary" @click="openUpdateModal(sale)">修改</button>
                        <button class="btn btn-danger" @click="deleteSales(sale)">删除</button>
                    </div>
                </td>
            </tr>
        </table>

        <!-- 更新售出信息的模态对话框 -->
        <div v-if="showUpdateModal" class="modal">
            <div class="modal-content">
                <h2 class="modal-title">更新售出信息</h2>
                <input v-model="currentSale.productID" placeholder="产品ID" class="form-control" />
                <input v-model="currentSale.saleTime" placeholder="售出时间" class="form-control" />
                <input v-model="currentSale.actualUnitPrice" placeholder="实际单价" class="form-control" />
                <input v-model="currentSale.soldQuantity" placeholder="售出数量" class="form-control" />
                <input v-model="currentSale.memberID" placeholder="会员ID" class="form-control" />
                <div class="modal-buttons">
                    <button @click="updateSales(currentSale)" class="btn btn-primary">提交修改</button>
                    <button @click="showUpdateModal = false" class="btn btn-secondary">取消</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    name: 'Sales',
    data() {
        return {
            sales: [],
            newSale: {
                productID: '',
                saleTime: '',
                actualUnitPrice: '',
                soldQuantity: '',
                memberID: ''
            },
            showUpdateModal: false, // 控制模态对话框的显示
            currentSale: {} // 当前正在修改的售出
        }
    },
    created() {
        axios.get('/api/sales/all')
            .then(response => {
                this.sales = response.data;
            });
    },
    methods: {
        openUpdateModal(sale) {
            this.currentSale = Object.assign({}, sale); // 复制售出对象
            this.showUpdateModal = true; // 显示模态对话框
        },
        updateSales(sale) {
            axios.post('/api/sales/update', sale, {
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })
                .then(response => {
                    // 更新成功
                    this.showUpdateModal = false; // 关闭模态对话框
                    // 更新售出列表中的信息
                    const index = this.sales.findIndex(s => s.salesID === sale.salesID);
                    this.sales.splice(index, 1, sale);
                }).catch(error => {
                    // 请求失败，弹出错误信息
                    this.$buefy.toast.open({
                        duration: 5000,
                        message: `添加产品失败：${error}`,
                        position: 'is-bottom',
                        type: 'is-danger'
                    });
                });
        },
        insertSales(sale) {
            axios.post('/api/sales/insert', sale, {
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })
                .then(response => {
                    // 插入成功
                    //this.sales.push(sale);
                    // 从服务器响应更新
                    const inserted = response.data;
                    this.sales.push(inserted);
                }).catch(error => {
                    // 请求失败，弹出错误信息
                    this.$buefy.toast.open({
                        duration: 5000,
                        message: `添加产品失败：${error}`,
                        position: 'is-bottom',
                        type: 'is-danger'
                    });
                });
        },
        deleteSales(sale) {
            axios.get(`/api/sales/delete/${sale.salesID}`)
                .then(response => {
                    // 删除成功
                    const index = this.sales.indexOf(sale);
                    this.sales.splice(index, 1);
                });
        }
    }
}
</script>

<style src="../assets/table.css"></style>