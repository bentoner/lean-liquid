import category_theory.Fintype

-- Remove when #13984 lands, and use `Fintype.equiv_equiv_iso` instead.

namespace Fintype

/-- An equivalence between finite types induces an isomorphism in `Fintype`. -/
@[simps]
def iso_of_equiv {A B : Fintype} (e : A ≃ B) : A ≅ B :=
{ hom := e,
  inv := e.symm,
  hom_inv_id' := by { ext t, change e.symm (e t) = t, simp },
  inv_hom_id' := by { ext t, change e (e.symm t) = t, simp } }

end Fintype
