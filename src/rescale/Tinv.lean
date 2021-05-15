import pseudo_normed_group.Tinv
import rescale.CLC

open_locale classical nnreal
noncomputable theory
local attribute [instance] type_pow
open opposite ProFiltPseuNormGrpWithTinv category_theory

universe variable u
variables (r : ℝ≥0) (V : SemiNormedGroup) [normed_with_aut r V] [fact (0 < r)]
variables (r' : ℝ≥0) [fact (0 < r')] [fact (r' ≤ 1)]
variables (M : ProFiltPseuNormGrpWithTinv.{u} r')
variables (c c₁ c₂ c₃ c₄ : ℝ≥0) {m n : ℕ}

namespace breen_deligne

open CLCFPTinv

namespace universal_map

variables (ϕ : universal_map m n)

local attribute [semireducible] CLCFPTinv₂ CLCFPTinv₂.res
  breen_deligne.universal_map.eval_CLCFPTinv₂

theorem eval_CLCFPTinv₂_rescale
  [fact (c₂ ≤ r' * c₁)] [fact (c₄ ≤ r' * c₃)] [ϕ.suitable c₃ c₁] [ϕ.suitable c₄ c₂]
  (N : ℝ≥0) [fact (c₂ * N⁻¹ ≤ r' * (c₁ * N⁻¹))] [fact (c₄ * N⁻¹ ≤ r' * (c₃ * N⁻¹))]
  (M : ProFiltPseuNormGrpWithTinv r') :
  arrow.mk ((eval_CLCFPTinv₂ r V r' c₁ c₂ c₃ c₄ ϕ).app (op (of r' (rescale N M)))) =
  arrow.mk ((eval_CLCFPTinv₂ r V r' (c₁ * N⁻¹) (c₂ * N⁻¹) (c₃ * N⁻¹) (c₄ * N⁻¹) ϕ).app (op M)) :=
begin
  dsimp only [universal_map.eval_CLCFPTinv₂, _root_.id, SemiNormedGroup.equalizer.map_nat_app],
  refine SemiNormedGroup.equalizer.map_congr _ _ rfl rfl rfl rfl;
  { exact universal_map.eval_CLCFP_rescale V r' _ _ _ _ _ N M },
end

end universal_map
end breen_deligne
