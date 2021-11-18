from numba import cuda
import numpy as np
import math
import random

@cuda.jit
def scoring_matrix(H, F, H_, E_, seq1, seq2):
    gap_open_penalty = 10
    gap_extend_penalty = 0.5
    match = 5
    mismatch = -4

    j = cuda.grid(1)
    g = cuda.cg.this_grid()

    if j > 0:
        for i in range(1, H.shape[0]):
            F[i, j] = max(F[i - 1, j], H[i - 1, j] - gap_open_penalty) - gap_extend_penalty
            H_[j] = max(H[i - 1, j - 1] + (match if seq1[i - 1] == seq2[j - 1] else mismatch), F[i, j], 0)
            E_[j] = max([H_[j - k] - k * gap_extend_penalty for k in range(j)])
            H[i, j] = max(H_[j], E_[j] - gap_open_penalty)

            g.sync()

def main():
    seq1 = [random.choice('CGTA') for _ in range(300)]
    seq2 = [random.choice('CGTA') for _ in range(400)]
    H = np.zeros((len(seq1) + 1, len(seq2) + 1))
    F = np.zeros((len(seq1) + 1, len(seq2) + 1))
    H_ = np.zeros(len(seq2) + 1) - np.inf
    E_ = np.zeros(len(seq2) + 1) - np.inf

    threads_per_block = 128
    blocks_per_grid = math.ceil(H.shape[1] / threads_per_block)

    scoring_matrix[blocks_per_grid, threads_per_block](H, F, H_, E_, seq1, seq2)

    print(H)

    np.save('scoring_matrix', H)

main()
