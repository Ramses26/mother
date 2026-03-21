import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const isAuthenticated = ref(false)
  const setupRequired = ref(false)

  function setAuthenticated(val) {
    isAuthenticated.value = val
  }

  function setSetupRequired(val) {
    setupRequired.value = val
  }

  return { isAuthenticated, setupRequired, setAuthenticated, setSetupRequired }
})
