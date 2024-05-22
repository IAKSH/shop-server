<template>
    <div class="container">
        <h1 class="title">进货</h1>

        <!-- 添加新进货的表单 -->
        <div class="form-group">
            <input v-model="newPurchase.productID" placeholder="产品ID" class="form-control" />
            <input v-model="newPurchase.purchaseTime" placeholder="进货时间" class="form-control" />
            <input v-model="newPurchase.purchaseUnitPrice" placeholder="进货单价" class="form-control" />
            <input v-model="newPurchase.purchaseQuantity" placeholder="进货数量" class="form-control" />
            <input v-model="newPurchase.sourceID" placeholder="来源ID" class="form-control" />
            <button @click="insertPurchase(newPurchase)" class="btn btn-success">添加进货记录</button>
        </div>

        <!-- 显示进货信息的表格 -->
        <table class="table">
            <tr>
                <th>产品ID</th>
                <th>进货时间</th>
                <th>进货单价</th>
                <th>进货数量</th>
                <th>来源ID</th>
                <th>操作</th>
            </tr>
            <tr v-for="purchase in purchases" :key="purchase.purchaseID">
                <td>{{ purchase.productID }}</td>
                <td>{{ purchase.purchaseTime }}</td>
                <td>{{ purchase.purchaseUnitPrice }}</td>
                <td>{{ purchase.purchaseQuantity }}</td>
                <td>{{ purchase.sourceID }}</td>
                <td>
                    <div class="btn-group">
                        <button class="btn btn-primary" @click="openUpdateModal(purchase)">修改</button>
                        <button class="btn btn-danger" @click="deletePurchase(purchase)">删除</button>
                    </div>
                </td>
            </tr>
        </table>

        <!-- 更新进货信息的模态对话框 -->
        <div v-if="showUpdateModal" class="modal">
            <div class="modal-content">
                <h2 class="modal-title">更新进货信息</h2>
                <input v-model="currentPurchase.productID" placeholder="产品ID" class="form-control" />
                <input v-model="currentPurchase.purchaseTime" placeholder="进货时间" class="form-control" />
                <input v-model="currentPurchase.purchaseUnitPrice" placeholder="进货单价" class="form-control" />
                <input v-model="currentPurchase.purchaseQuantity" placeholder="进货数量" class="form-control" />
                <input v-model="currentPurchase.sourceID" placeholder="来源ID" class="form-control" />
                <div class="modal-buttons">
                    <button @click="updatePurchase(currentPurchase)" class="btn btn-primary">提交修改</button>
                    <button @click="showUpdateModal = false" class="btn btn-secondary">取消</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    name: 'Purchase',
    data() {
        return {
            purchases: [],
            newPurchase: {
                productID: '',
                purchaseTime: '',
                purchaseUnitPrice: '',
                purchaseQuantity: '',
                sourceID: ''
            },
            showUpdateModal: false, // 控制模态对话框的显示
            currentPurchase: {} // 当前正在修改的进货
        }
    },
    created() {
        axios.get('/api/purchase/all')
            .then(response => {
                this.purchases = response.data;
            });
    },
    methods: {
        openUpdateModal(purchase) {
            this.currentPurchase = Object.assign({}, purchase); // 复制进货对象
            this.showUpdateModal = true; // 显示模态对话框
        },
        updatePurchase(purchase) {
            axios.post('/api/purchase/update', purchase, {
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })
                .then(response => {
                    // 更新成功
                    this.showUpdateModal = false; // 关闭模态对话框
                    // 更新进货列表中的信息
                    const index = this.purchases.findIndex(p => p.purchaseID === purchase.purchaseID);
                    this.purchases.splice(index, 1, purchase);
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
        insertPurchase(purchase) {
            axios.post('/api/purchase/insert', purchase, {
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })
                .then(response => {
                    // 插入成功
                    //this.purchases.push(purchase);
                    // 从服务器响应更新
                    const inserted = response.data;
                    this.purchases.push(inserted);
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
        deletePurchase(purchase) {
            axios.get(`/api/purchase/delete/${purchase.purchaseID}`)
                .then(response => {
                    // 删除成功
                    const index = this.purchases.indexOf(purchase);
                    this.purchases.splice(index, 1);
                });
        }
    }
}
</script>

<style src="../assets/table.css"></style>