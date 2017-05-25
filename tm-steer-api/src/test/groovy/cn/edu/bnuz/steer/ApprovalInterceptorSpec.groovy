package cn.edu.bnuz.steer


import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.web.ControllerUnitTestMixin} for usage instructions
 */
@TestFor(ApprovalInterceptor)
class ApprovalInterceptorSpec extends Specification {

    def setup() {
    }

    def cleanup() {

    }

    void "Test approval interceptor matching"() {
        when:"A request matches the interceptor"
            withRequest(controller:"approval")

        then:"The interceptor does match"
            interceptor.doesMatch()
    }
}
