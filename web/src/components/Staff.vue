<template>
    <div class="container">
        <h1 class="title">员工</h1>

        <!-- 添加新员工的表单 -->
        <div class="form-group">
            <input v-model="newStaff.name" placeholder="姓名" class="form-control" />
            <input v-model="newStaff.gender" placeholder="性别" class="form-control" />
            <input v-model="newStaff.age" placeholder="年龄" class="form-control" />
            <input v-model="newStaff.monthlySalary" placeholder="月薪" class="form-control" />
            <button @click="insertStaff(newStaff)" class="btn btn-success">添加员工记录</button>
        </div>

        <!-- 显示员工信息的表格 -->
        <table class="table">
            <tr>
                <th>姓名</th>
                <th>性别</th>
                <th>年龄</th>
                <th>月薪</th>
                <th>操作</th>
            </tr>
            <tr v-for="staff in staffs" :key="staff.staffID">
                <td>{{ staff.name }}</td>
                <td>{{ staff.gender }}</td>
                <td>{{ staff.age }}</td>
                <td>{{ staff.monthlySalary }}</td>
                <td>
                    <div class="btn-group">
                        <button class="btn btn-primary" @click="openUpdateModal(staff)">修改</button>
                        <button class="btn btn-danger" @click="deleteStaff(staff)">删除</button>
                    </div>
                </td>
            </tr>
        </table>

        <!-- 更新员工信息的模态对话框 -->
        <div v-if="showUpdateModal" class="modal">
            <div class="modal-content">
                <h2 class="modal-title">更新员工信息</h2>
                <input v-model="currentStaff.name" placeholder="姓名" class="form-control" />
                <input v-model="currentStaff.gender" placeholder="性别" class="form-control" />
                <input v-model="currentStaff.age" placeholder="年龄" class="form-control" />
                <input v-model="currentStaff.monthlySalary" placeholder="月薪" class="form-control" />
                <div class="modal-buttons">
                    <button @click="updateStaff(currentStaff)" class="btn btn-primary">提交修改</button>
                    <button @click="showUpdateModal = false" class="btn btn-secondary">取消</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    name: 'Staff',
    data() {
        return {
            staffs: [],
            newStaff: {
                name: '',
                gender: '',
                age: '',
                monthlySalary: ''
            },
            showUpdateModal: false, // 控制模态对话框的显示
            currentStaff: {} // 当前正在修改的员工
        }
    },
    created() {
        axios.get('/api/staff/all')
            .then(response => {
                this.staffs = response.data;
            });
    },
    methods: {
        openUpdateModal(staff) {
            this.currentStaff = Object.assign({}, staff); // 复制员工对象
            this.showUpdateModal = true; // 显示模态对话框
        },
        updateStaff(staff) {
            axios.post('/api/staff/update', staff, {
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })
                .then(response => {
                    // 更新成功
                    this.showUpdateModal = false; // 关闭模态对话框
                    // 更新员工列表中的信息
                    const index = this.staffs.findIndex(s => s.staffID === staff.staffID);
                    this.staffs.splice(index, 1, staff);
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
        insertStaff(staff) {
            axios.post('/api/staff/insert', staff, {
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })
                .then(response => {
                    // 插入成功
                    //this.staffs.push(staff);
                    // 从服务器响应更新
                    const inserted = response.data;
                    this.staffs.push(inserted);
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
        deleteStaff(staff) {
            axios.get(`/api/staff/delete/${staff.staffID}`)
                .then(response => {
                    // 删除成功
                    const index = this.staffs.indexOf(staff);
                    this.staffs.splice(index, 1);
                });
        }
    }
}
</script>

<style src="../assets/table.css"></style>
