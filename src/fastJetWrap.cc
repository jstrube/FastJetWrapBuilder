#include "jlcxx/jlcxx.hpp"
#include "fjcore.hh"
#include <vector>

using namespace std;
using namespace fjcore;
namespace jlcxx
{
    template<> struct IsBits<JetAlgorithm> : std::true_type {};
    template<> struct IsBits<RecombinationScheme> : std::true_type {};
    template<> struct IsBits<Strategy> : std::true_type {};
}
JLCXX_MODULE define_julia_module(jlcxx::Module& fastjet)
{
    fastjet.add_bits<JetAlgorithm>("JetAlgorithm");
    fastjet.set_const("kt_algorithm", kt_algorithm);
    fastjet.set_const("cambridge_algorithm", cambridge_algorithm);
    fastjet.set_const("antikt_algorithm", antikt_algorithm);
    fastjet.set_const("genkt_algorithm", genkt_algorithm);
    fastjet.set_const("cambridge_for_passive_algorithm", cambridge_for_passive_algorithm);
    fastjet.set_const("genkt_for_passive_algorithm", genkt_for_passive_algorithm);
    fastjet.set_const("ee_kt_algorithm", ee_kt_algorithm);
    fastjet.set_const("ee_genkt_algorithm", ee_genkt_algorithm);
    fastjet.set_const("plugin_algorithm", plugin_algorithm);
    fastjet.set_const("undefined_jet_algorithm", undefined_jet_algorithm);

    fastjet.add_bits<RecombinationScheme>("RecombinationScheme");
    fastjet.set_const("E_scheme", E_scheme);
    fastjet.set_const("pt_scheme", pt_scheme);
    fastjet.set_const("pt2_scheme", pt2_scheme);
    fastjet.set_const("Et_scheme", Et_scheme);
    fastjet.set_const("Et2_scheme", Et2_scheme);
    fastjet.set_const("BIpt_scheme", BIpt_scheme);
    fastjet.set_const("BIpt2_scheme", BIpt2_scheme);
    fastjet.set_const("WTA_pt_scheme", WTA_pt_scheme);
    fastjet.set_const("WTA_modp_scheme", WTA_modp_scheme);
    fastjet.set_const("external_scheme", external_scheme);

    fastjet.add_bits<Strategy>("Strategy");
    fastjet.set_const("N2MHTLazy9AntiKtSeparateGhosts", N2MHTLazy9AntiKtSeparateGhosts);
    fastjet.set_const("N2MHTLazy9", N2MHTLazy9);
    fastjet.set_const("N2MHTLazy25", N2MHTLazy25);
    fastjet.set_const("N2MHTLazy9Alt", N2MHTLazy9Alt);
    fastjet.set_const("N2MinHeapTiled", N2MinHeapTiled);
    fastjet.set_const("N2Tiled", N2Tiled);
    fastjet.set_const("N2PoorTiled", N2PoorTiled);
    fastjet.set_const("N2Plain", N2Plain);
    fastjet.set_const("N3Dumb", N3Dumb);
    fastjet.set_const("Best", Best);
    fastjet.set_const("NlnN", NlnN);
    fastjet.set_const("NlnN3pi", NlnN3pi);
    fastjet.set_const("NlnN4pi", NlnN4pi);
    fastjet.set_const("NlnNCam4pi", NlnNCam4pi);
    fastjet.set_const("NlnNCam2pi2R", NlnNCam2pi2R);
    fastjet.set_const("NlnNCam", NlnNCam);
    fastjet.set_const("BestFJ30", BestFJ30);
    fastjet.set_const("plugin_strategy", plugin_strategy);

    fastjet.add_type<PseudoJet>("PseudoJet")
    .constructor<const double, const double, const double, const double>()
    .method("E", &PseudoJet::E)
    .method("e", &PseudoJet::e)
    .method("px", &PseudoJet::px)
    .method("py", &PseudoJet::py)
    .method("pz", &PseudoJet::pz)
    .method("phi", &PseudoJet::phi)
    .method("phi_std", &PseudoJet::phi_std)
    .method("phi_02pi", &PseudoJet::phi_02pi)
    .method("rap", &PseudoJet::rap)
    .method("rapidity", &PseudoJet::rapidity)
    .method("pseudorapidity", &PseudoJet::pseudorapidity)
    .method("eta", &PseudoJet::eta)
    .method("pt2", &PseudoJet::pt2)
    .method("pt", &PseudoJet::pt)
    .method("perp2", &PseudoJet::perp2)
    .method("perp", &PseudoJet::perp)
    .method("kt2", &PseudoJet::kt2)
    .method("m2", &PseudoJet::m2)
    .method("m", &PseudoJet::m)
    .method("mperp2", &PseudoJet::mperp2)
    .method("mperp", &PseudoJet::mperp)
    .method("mt2", &PseudoJet::mt2)
    .method("mt", &PseudoJet::mt)
    .method("modp2", &PseudoJet::modp2)
    .method("modp", &PseudoJet::modp)
    .method("Et", &PseudoJet::Et)
    .method("Et2", &PseudoJet::Et2)
    .method("operator[]", &PseudoJet::operator[])
    .method("kt_distance", &PseudoJet::kt_distance)
    .method("plain_distance", &PseudoJet::plain_distance)
    .method("squared_distance", &PseudoJet::squared_distance)
    .method("delta_R", &PseudoJet::delta_R)
    .method("delta_phi_to", &PseudoJet::delta_phi_to)
    .method("beam_distance", &PseudoJet::beam_distance)
    .method("four_mom", &PseudoJet::four_mom);

    // we mostly don't need the jet definition on the julia side.
    // only used to instantiate the clustering
    fastjet.add_type<JetDefinition>("JetDefinition")
    .constructor<const JetAlgorithm, double>();

    fastjet.add_type<vector<PseudoJet>>("JetVec")
    .method("size", &vector<PseudoJet>::size);
    fastjet.method("at", [](const vector<PseudoJet>& vec, size_t i) {
        return vec.at(i);
    });

    fastjet.method("constituents", [](const PseudoJet& pj) {
		return pj.constituents();
	});

    fastjet.method("ClusterSequence", [](jlcxx::ArrayRef<jl_value_t*> vec, const JetDefinition& jd) {
        vector<PseudoJet> pjvec;
        for(jl_value_t* v : vec) {
            const PseudoJet& j = *jlcxx::unbox_wrapped_ptr<PseudoJet>(v);
            pjvec.push_back(j);
        }
        return ClusterSequence(pjvec, jd);
    });

    fastjet.add_type<ClusterSequence>("ClusterSequence")
    .constructor<const std::vector<PseudoJet>&, const JetDefinition&>()
    .method("inclusive_jets", &ClusterSequence::inclusive_jets);
}
