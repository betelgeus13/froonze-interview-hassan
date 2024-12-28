<template>
  <div v-if="totalPages > 1" class="pagination-controls">
    <button :disabled="currentPage === 1" @click="goToPage(1)">First</button>
    <button :disabled="currentPage === 1" @click="goToPage(currentPage - 1)">Previous</button>
    <span v-for="page in pagesToShow" :key="page">
      <button
        :class="{ active: currentPage === page }"
        @click="goToPage(page)"
      >
        {{ page }}
      </button>
    </span>
    <button
      :disabled="currentPage === totalPages"
      @click="goToPage(currentPage + 1)"
    >
      Next
    </button>
    <button
      :disabled="currentPage === totalPages"
      @click="goToPage(totalPages)"
    >
      Last
    </button>
  </div>
</template>

<script>
  export default {
    props: {
      currentPage: {
        type: Number,
        required: true,
      },
      totalPages: {
        type: Number,
        required: true,
      },
      range: {
        type: Number,
        default: 2, // Default range for pages to show around the current page
      },
    },

    computed: {
      pagesToShow() {
        const start = Math.max(1, this.currentPage - this.range);
        const end = Math.min(this.totalPages, this.currentPage + this.range);
        return Array.from({ length: end - start + 1 }, (_, i) => i + start);
      },
    },

    methods: {
      goToPage(page) {
        this.$emit('page-changed', page);
      },
    },
  };
</script>

<style scoped>
  .pagination-controls {
    display: flex;
    justify-content: center;
    align-items: center;
    margin-top: 20px;
  }

  .pagination-controls button {
    margin: 0 5px;
    padding: 5px 10px;
    font-size: 14px;
    cursor: pointer;
  }

  .pagination-controls button.active {
    font-weight: bold;
    background-color: #007bff;
    color: white;
  }

  .pagination-controls button:disabled {
    cursor: not-allowed;
    opacity: 0.6;
  }
</style>
